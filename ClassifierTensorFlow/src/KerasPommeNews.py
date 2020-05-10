from __future__ import absolute_import, division, print_function, unicode_literals

from typing import List

import tensorflow as tf

from ManualTestPrint import ManualTestPrint
from classifier.evaluation.model_evaluator import ModelEvaluator
from classifier.prediction.article_predictor import ArticlePredictor
from classifier.prediction.models.ClassifierModel1 import ClassifierModel1
from classifier.prediction.models.ClassifierModel2 import ClassifierModel2
from classifier.prediction.models.DatasetWrapper import DatasetWrapper
from classifier.preprocessing.article_preprocessor_swift import ArticlePreprocessorSwift
from classifier.preprocessing.article_text_tokenizer import ArticleTextTokenizer
from classifier.preprocessing.article_theme_tokenizer import ArticleThemeTokenizer
from data_models.ThemeStat import ThemeStat
from data_models.articles import Articles
from data_models.weights.theme_weights import ThemeWeights

print("\n\n\n####################################\n####################################")

############################################
# Configuration
############################################

# DATA CONFIGURATION
# ------------------

ARTICLE_JSON_FILE = "articles_{}.json"
LANG = "fr"
LANG_FULL = "french"

# supportedThemes: List[str] = ["google", "apple", "microsoft", "samsung", "amazon", "facebook", "netflix", "spotify", "android", "ios", "iphone", "smartphone", "tablet", "ipad", "tablet", "appleWatch", "watch", "economyPolitic", "videoService", "audioService", "cloudService", "surface", "crypto", "health", "keynote", "rumor", "cloudComputing", "patent", "lawsuitLegal", "study", "future", "test", "appleMusic", "appleTVPlus", "security", "apps", "windows", "macos"]
# supportedThemes: List[str] = ["android", "ios", "windows", "macos", "otherOS"]
# supportedThemes: List[str] = ["tablet", "smartphone", "watch", "computer", "speaker", "component", "accessory"]

SUPPORTED_THEMES: List[str] = ["tablet", "smartphone", "watch", "computer"]
# SUPPORTED_THEMES: List[str] = ["computer", "smartphone"]

# MACHINE LEARNING CONFIGURATION
# ------------------------------

# preprocessor: ArticlePreprocessor = ArticlePreprocessor(LANG_FULL)
PREPROCESSOR = ArticlePreprocessorSwift()
DATASET_BATCH_SIZE = 100
ARTICLE_MAX_WORD_COUNT = 100
TRAIN_RATIO = 0.65
VALIDATION_RATIO = 0.17  # TEST if 1 - TRAIN_RATIO - VALIDATION_RATIO
VOCABULARY_MAX_SIZE = 50000  # not used for now!

# BEHAVIOUR CONFIGURATION
LIMIT_ARTICLES_TRAINING = False  # True or False
LIMIT_ARTICLES_PREDICTION = None  # None or a number

DO_COMPARISONS = False
POST_ALL_CLASSIFY = False


############################################
# Data loading
############################################


# Loading the file
# ============================

articles_filepath = ARTICLE_JSON_FILE.format(LANG)

if LIMIT_ARTICLES_TRAINING:
    all_articles: Articles = Articles.from_file(articles_filepath, 600)
else:
    all_articles: Articles = Articles.from_file(articles_filepath)

all_articles.shuffle()

articles: Articles = all_articles.articles_with_all_verified_themes(SUPPORTED_THEMES)

# Data filtering and preprocessing
# ============================

# Removal of all unsupported themes and keep only data_models who have at least one supported theme.
# -----------

all_articles_count: int = all_articles.count()

for article in articles.items:
    article.themes = [value for value in article.themes if value in SUPPORTED_THEMES]
    article.verified_themes = [value for value in article.verified_themes if value in SUPPORTED_THEMES]
    article.predicted_themes = [value for value in article.predicted_themes if value in SUPPORTED_THEMES]

articles_count = articles.count()

print("Removed {} data_models over {} without any supported themes. Left {}".format(all_articles_count - articles_count,
                                                                                    all_articles_count, articles_count))

# Removal of stopwords and lemmatization, lower-casing, etc
# -----------

articles = PREPROCESSOR.process_articles(articles=articles)

# Creation of tokenizer and apply them.
# ===================================

tokenizer: ArticleTextTokenizer = ArticleTextTokenizer(articles, ARTICLE_MAX_WORD_COUNT)
theme_tokenizer: ArticleThemeTokenizer = ArticleThemeTokenizer(articles)

X = tokenizer.sequences
Y = theme_tokenizer.one_hot_matrix

################################################################################################
# Data Analysis Section
################################################################################################

# Theme statistic
# -----------

print("\n\nData Analysis")
print("-------------")

theme_stats: List[ThemeStat] = []

for theme in SUPPORTED_THEMES:
    article_with_theme = articles.articles_with_theme(theme).items
    stat = ThemeStat(theme, len(article_with_theme), articles.count())
    theme_stats.append(stat)
    print("'{}' {} / {}".format(theme, stat.article_count, stat.total_article_count))


################################################################################################
# Machine Learning Section
################################################################################################

print("\n\nStarting Machine Learning")
print("-------------------------")

# Important Variables to be used later on.
# ===================================

voc_size = tokenizer.voc_size  # +1 because we pad with 0.
theme_count = theme_tokenizer.themes_count  # + 1

print("Data input:")
print("* Number of data_models: ", tokenizer.document_count)
print("* Size of vocabulary: ", voc_size)
print("* Number of themes: ", theme_count)
print("\n")

theme_weight = ThemeWeights(theme_stats, theme_tokenizer).to_weights()

# Creation of dataset
# ============================

dataset: tf.data.Dataset = tf.data.Dataset.from_tensor_slices((X, Y))

# Evaluation of a model
# ============================

# For brands
# model = modelCreator.create_model(embedding_output_dim=128, intermediate_dim=256, last_dim=64, epochs=70)

# For device type
# model = modelCreator.create_model(embedding_output_dim=128, intermediate_dim=256, last_dim=256, epochs=20)
# model = modelCreator.create_model(embedding_output_dim=128, intermediate_dim=256, last_dim=256, epochs=20)

datasetWrapped = DatasetWrapper(tf_dataset=dataset,
                                train_ratio=TRAIN_RATIO,
                                validation_ratio=VALIDATION_RATIO
                                )

# do_ theme_weight for each theme!
modelCreator = ClassifierModel1(theme_weight, datasetWrapped, voc_size)
# modelCreator = ClassifierModel2(theme_weight, datasetWrapped, voc_size)

# model = modelCreator.create_model()
model = modelCreator.create_model(196, 512, 512, epochs=40)

if modelCreator.is_valid() is False:
    raise Exception("The model creator is invalid.")

################################################################################################
# Manual Tests of the created model
################################################################################################

if POST_ALL_CLASSIFY:
    testPrint = ManualTestPrint(articles.title_and_summary(),
                                articles.themes(),
                                ARTICLE_MAX_WORD_COUNT,
                                model,
                                theme_tokenizer
                                )
    testPrint.print()

print("\nThemes idx:", theme_tokenizer.tokenizer.word_index)

################################################################################################
# Classify unclassified data_models
################################################################################################

predictor = ArticlePredictor(model,
                             SUPPORTED_THEMES,
                             PREPROCESSOR,
                             tokenizer,
                             theme_tokenizer)

predictor.limit_predictions = LIMIT_ARTICLES_PREDICTION

predictions = predictor.predict(all_articles)

evaluator = ModelEvaluator()

evaluator.evaluate(all_articles, SUPPORTED_THEMES)

print("DONE!!!")
