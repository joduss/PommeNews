from __future__ import absolute_import, division, print_function, unicode_literals

from typing import List, Dict

from tensorflow.python.keras.preprocessing.text import Tokenizer

import tensorflow as tf
import numpy as np
import tensorflow.keras as keras


from classifier.prediction.models.ClassifierModel2 import ClassifierModel2
from classifier.prediction.models.DatasetWrapper import DatasetWrapper
from data_models.ThemeStat import ThemeStat
from classifier.preprocessing.article_preprocessor import ArticlePreprocessor
from data_models.articles import Articles
from classifier.prediction.models.ClassifierModel1Creator import ClassifierModel1Creator
from classifier.prediction.article_predictor import ArticlePredictor
from ManualTestPrint import ManualTestPrint
from classifier.evaluation.model_evaluator import ModelEvaluator

print("\n\n\n####################################\n####################################")

############################################
# Configuration
############################################

DO_COMPARISONS = False
POST_ALL_CLASSIFY = False

DATASET_BATCH_SIZE = 100
ARTICLE_MAX_WORD_COUNT = 100
TRAIN_RATIO = 0.65
VALIDATION_RATIO = 0.17 # TEST if 1 - TRAIN_RATIO - VALIDATION_RATIO
VOCABULARY_MAX_SIZE = 50000 # not used for now!

ARTICLE_JSON_FILE = "articles_{}.json"
LANG = "fr"
LANG_FULL = "french"

LIMIT_ARTICLES_TRAINING = True
LIMIT_ARTICLES_PREDICTION = 600 # None or a number

# supportedThemes: List[str] = ["google", "apple", "microsoft", "samsung", "amazon", "facebook", "netflix", "spotify", "android", "ios", "iphone", "smartphone", "tablet", "ipad", "tablet", "appleWatch", "watch", "economyPolitic", "videoService", "audioService", "cloudService", "surface", "crypto", "health", "keynote", "rumor", "cloudComputing", "patent", "lawsuitLegal", "study", "future", "test", "appleMusic", "appleTVPlus", "security", "apps", "windows", "macos"]
# supportedThemes: List[str] = ["android", "ios", "windows", "macos", "otherOS"]
#supportedThemes: List[str] = ["tablet", "smartphone", "watch", "computer", "speaker", "component", "accessory"]

#SUPPORTED_THEMES: List[str] = ["tablet", "smartphone", "watch", "computer"]
SUPPORTED_THEMES: List[str] = ["computer", "smartphone"]


# Printing config
# ============================

print("TensorFlow version: ", tf.version.VERSION)
print("Keras version: ", tf.keras.__version__)


############################################
# Configuration of model
############################################



# Loading the file
# ============================

articles_filepath = ARTICLE_JSON_FILE.format(LANG)

if (LIMIT_ARTICLES_TRAINING):
    all_articles: Articles = Articles.from_file(articles_filepath, 600)
else:
    all_articles: Articles = Articles.from_file(articles_filepath)

all_articles.shuffle()

articles: Articles = all_articles.articles_with_all_verified_themes(SUPPORTED_THEMES)


# Preprocessing of data
# ============================

# Lowercasing
# -----------

for article in articles.items:
    article.title = article.title.lower()
    article.summary = article.summary.lower()


# Removal of all unsupported themes and keep only data_models who have at least one supported theme.
# -----------

all_articles_count: int = all_articles.count()

for article in articles.items:
    article.themes = [value for value in article.themes if value in SUPPORTED_THEMES]
    article.verified_themes = [value for value in article.verified_themes if value in SUPPORTED_THEMES]
    article.predicted_themes = [value for value in article.predicted_themes if value in SUPPORTED_THEMES]

articles_count = articles.count()

print("Removed {} data_models over {} without any supported themes. Left {}".format(all_articles_count - articles_count, all_articles_count, articles_count))


# Removal of stopwords and lemmatization
# -----------

preprocessor: ArticlePreprocessor = ArticlePreprocessor(LANG_FULL)
articles.items = preprocessor.process_articles(articles.items)


# Creation of tokenizer and apply them.
# ===================================

tokenizer: Tokenizer = Tokenizer()
tokenizer.fit_on_texts(articles.title_and_summary())

X = tokenizer.texts_to_sequences(articles.title_and_summary())

themeTokenizer: Tokenizer = Tokenizer()
themeTokenizer.fit_on_texts(articles.themes())

Y = themeTokenizer.texts_to_matrix(articles.themes())
#Y = tf.one_hot(themeTokenizer.texts_to_sequences(articles.themes()), depth=len(SUPPORTED_THEMES))


# Remove the first column, whose first col contains only 0s.
Y = np.delete(arr=Y, obj=0, axis=1)

# for y in Y:
#     for i in range(0, y.size):
#         y[i] = y[i] * (i+1)


# Create ordered list of theme as in tokenizer
orderedThemes = []

for i in range(1, len(themeTokenizer.word_index) + 1):  # word_index start at 1, 0 is reserved.
    orderedThemes.append(themeTokenizer.index_word[i])


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

voc_size = len(tokenizer.word_index) + 1 # +1 because we pad with 0.
theme_count = len(themeTokenizer.word_index) #+ 1

print("Data input:")
print("* Number of data_models: ", tokenizer.document_count)
print("* Size of vocabulary: ", voc_size)
print("* Number of themes: ", theme_count)
print("\n")


theme_weight: List[float] = []
for theme in orderedThemes:
    stat = [stat for stat in theme_stats if stat.theme == theme][0]
    # theme_weight.append(1 / stat.weight())
    theme_weight.append(1 / stat.weight())

# Padding of data
# ============================

# Padding to make all feature vector the same length.
X = keras.preprocessing.sequence.pad_sequences(X,
                                               value=0,
                                               padding='post',
                                               maxlen=ARTICLE_MAX_WORD_COUNT)

#print("Padded X: ", X)
#print("Padded Y: ", Y)

# Creation of dataset
# ============================



dataset: tf.data.Dataset = tf.data.Dataset.from_tensor_slices((X,Y))
# dataset = dataset.batch(DATASET_BATCH_SIZE).repeat().shuffle(DATASET_BATCH_SIZE)
#
# trainSize = int(TRAIN_RATIO * len(X))
# validationSize = int(VALIDATION_RATIO * len(X))
# testSize = len(X) - trainSize - validationSize
#
#
# trainData = dataset.take(trainSize).repeat()
# validationData = dataset.skip(trainSize).take(validationSize).repeat()
# testData = dataset.skip(testSize)
#
# train_batch_count = int(math.ceil(trainSize / DATASET_BATCH_SIZE))
# test_batch_count = int(math.ceil(testSize / DATASET_BATCH_SIZE))
# validation_batch_count = int(math.ceil(validationSize / DATASET_BATCH_SIZE))





# Evaluation of a model
# ============================

# modelCreator: ClassifierModel1Creator = ClassifierModel1Creator(
#     article_length=ARTICLE_MAX_WORD_COUNT,
#     voc_size=voc_size,
#     theme_weight=theme_weigth,
#     theme_count=theme_count,
#     trainData=trainData,
#     train_batch_count=train_batch_count,
#     validationData=validationData,
#     validation_batch_count=validation_batch_count)

# For brands
#model = modelCreator.create_model(embedding_output_dim=128, intermediate_dim=256, last_dim=64, epochs=70)

# For device type
#model = modelCreator.create_model(embedding_output_dim=128, intermediate_dim=256, last_dim=256, epochs=20)
#model = modelCreator.create_model(embedding_output_dim=128, intermediate_dim=256, last_dim=256, epochs=20)

datasetWrapped = DatasetWrapper(tf_dataset=dataset,
                                train_ratio = TRAIN_RATIO,
                                validation_ratio=VALIDATION_RATIO
                                )

#do_ theme_weight for each theme!
modelCreator = ClassifierModel2(theme_weight, datasetWrapped, voc_size)

model = modelCreator.create_model()

model.save('model.h5')

print("\nPerform evaluation---")
#modelEvaluationResults = model.evaluate(testData, steps=test_batch_count)

#print("Evaluation results (loss, acc): ", modelEvaluationResults)


################################################################################################
# Manual Tests of the created model
################################################################################################

if POST_ALL_CLASSIFY:
    testPrint = ManualTestPrint(articles.title_and_summary(), articles.themes(), ARTICLE_MAX_WORD_COUNT, model, themeTokenizer)
    testPrint.print()

print("\nThemes idx:", themeTokenizer.word_index)


################################################################################################
# Classify unclassified data_models
################################################################################################

# Helper


predictor = ArticlePredictor(model,
                             SUPPORTED_THEMES,
                             preprocessor,
                             ARTICLE_MAX_WORD_COUNT,
                             tokenizer,
                             themeTokenizer)

predictor.limit_predictions = LIMIT_ARTICLES_PREDICTION

predictions = predictor.predict(all_articles)

evaluator = ModelEvaluator()

evaluator.evaluate(all_articles, SUPPORTED_THEMES)


print("DONE!!!")
