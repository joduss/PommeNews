from __future__ import absolute_import, division, print_function, unicode_literals

from typing import List

from tensorflow.python.keras.preprocessing.text import Tokenizer

import tensorflow as tf
import numpy as np
import tensorflow.keras as keras
import math
import json as jsonModule

import Plot ## required if plotting error.
from ArticlePreprocessor import ArticlePreprocessor
from ClassifierModel1Creator import ClassifierModel1Creator
from JsonArticlePredictor import JsonArticlePredictor
from ManualTestPrint import ManualTestPrint

print("\n\n\n####################################\n####################################")

############################################
# Configuration
############################################

DO_COMPARISONS = False
POST_ALL_CLASSIFY = False

DATASET_BATCH_SIZE = 100
ARTICLE_MAX_WORD_COUNT = 200
TRAIN_RATIO = 0.65
VALIDATION_RATIO = 0.17 # TEST if 1 - TRAIN_RATIO - VALIDATION_RATIO
VOCABULARY_MAX_SIZE = 50000 # not used for now!

LANG = "french"

file = open("articles_fr.json", "r")
# supportedThemes: List[str] = ["google", "apple", "microsoft", "samsung", "amazon", "facebook", "netflix", "spotify", "android", "ios", "iphone", "smartphone", "tablet", "ipad", "tablet", "appleWatch", "watch", "economyPolitic", "videoService", "audioService", "cloudService", "surface", "crypto", "health", "keynote", "rumor", "cloudComputing", "patent", "lawsuitLegal", "study", "future", "test", "appleMusic", "appleTVPlus", "security", "apps", "windows", "macos"]
# supportedThemes: List[str] = ["android", "ios", "windows", "macos", "otherOS"]
#supportedThemes: List[str] = ["tablet", "smartphone", "watch", "computer", "speaker", "component", "accessory"]
supportedThemes: List[str] = ["tablet", "smartphone", "watch", "computer"]


# Printing config
# ============================

print("TensorFlow version: ", tf.version.VERSION)
print("Keras version: ", tf.keras.__version__)


############################################
# Configuration of model
############################################

KEY_THEMES = "themes"
KEY_VERIFIED_THEMES = "verifiedThemes"
KEY_TITLE = "title"
KEY_SUMMARY = "summary"
KEY_PREDICTED_THEMES = "predictedThemes"

# Loading the file
# ============================

json = jsonModule.loads(file.read())

# Only keep articles which have themes.
# articles = [jsonObject["title"] + ". " + jsonObject["summary"] for jsonObject in json if len(jsonObject["themes"]) > 0]
all_orig_articles: List[str] = [jsonObject["title"] + ". " + jsonObject["summary"] for jsonObject in json if len(jsonObject["verifiedThemes"]) > 0]
all_themes: List[List[str]] = [jsonObject["themes"] for jsonObject in json if len(jsonObject["verifiedThemes"]) > 0]
all_verified_themes: List[List[str]] = [jsonObject["verifiedThemes"] for jsonObject in json if len(jsonObject["verifiedThemes"]) > 0]

# Preprocessing of data
# ============================

# Lowercasing
# -----------
articles = [article.lower() for article in all_orig_articles]

# Removal of all unsupported themes and keep only articles who have at least one supported theme.
# -----------

nbThemesBefore = len(articles)

articlesInFiltering = articles
themesInFiltering = all_themes

themes = []
articles = []

idx: int = 0
for articleThemes in themesInFiltering:
    filteredThemes = [value for value in articleThemes if value in supportedThemes]
    filteredVerifiedThemes = [value for value in all_verified_themes[idx] if value in supportedThemes]

    if len(filteredVerifiedThemes) > 0:
        if len(filteredThemes) > 0:
            themes.append(filteredThemes)
            articles.append(articlesInFiltering[idx])
        # else:
        #     articles.append(articlesInFiltering[idx])
        #     themes.append("none")

    # elif len(articleThemes) > 0:
    #     themes.append(["none"])
    #     articles.append(articlesInFiltering[idx])
    idx+=1

nbThemesAfter = len(articles)

print("Removed {} articles over {} without any supported themes. Left {}".format(nbThemesBefore - nbThemesAfter, nbThemesBefore, nbThemesAfter))

# Removal of stopwords and lemmatization
# -----------

preprocessor = ArticlePreprocessor(LANG)
articles = preprocessor.process_articles(articles)


# Creation of tokenizer and apply them.
# ===================================

tokenizer: Tokenizer = Tokenizer()
tokenizer.fit_on_texts(articles)

X = tokenizer.texts_to_sequences(articles)

themeTokenizer: Tokenizer = Tokenizer()
themeTokenizer.fit_on_texts(themes)

Y = themeTokenizer.texts_to_matrix(themes)

# Remove the first column, whose first col contains only 0s.
Y = np.delete(arr=Y, obj=0, axis=1)




################################################################################################
# Data Analysis Section
################################################################################################

orderedThemes = []
themeWeight = []
largestThemeArticleCount = 0

# Create ordered list of theme as in tokenizer
for i in range(1, len(themeTokenizer.word_index) + 1): # word_index start at 1, 0 is reserved.
    theme = themeTokenizer.index_word[i]
    orderedThemes.append(themeTokenizer.index_word[i])
    nbWithTheme = len([currentThemes for currentThemes in themes if theme in currentThemes])
    print("'{}' {} / {}".format(theme, nbWithTheme, len(themes)))
    themeWeight.append(nbWithTheme)

    if nbWithTheme > largestThemeArticleCount:
        largestThemeArticleCount = nbWithTheme

# Class weight is computed based on 1.0 = weight of the most likely class.

for i in range(0,len(themeWeight)):
    themeWeight[i] = largestThemeArticleCount / (themeWeight[i] + 0.0001)


print("\n\nData Analysis")
print("-------------")


for theme in supportedThemes:
    nbWithTheme = len([currentThemes for currentThemes in themes if theme in currentThemes])
    print("'{}' {} / {}".format(theme, nbWithTheme, len(themes)))




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
print("* Number of articles: ", tokenizer.document_count)
print("* Size of vocabulary: ", voc_size)
print("* Number of themes: ", theme_count)
print("\n")



# Shapding of data
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


dataset = tf.data.Dataset.from_tensor_slices((X,Y))
dataset = dataset.batch(DATASET_BATCH_SIZE).repeat().shuffle(DATASET_BATCH_SIZE)

trainSize = int(TRAIN_RATIO * len(X))
validationSize = int(VALIDATION_RATIO * len(X))
testSize = len(X) - trainSize - validationSize


trainData = dataset.take(trainSize).repeat()
validationData = dataset.skip(trainSize).take(validationSize).repeat()
testData = dataset.skip(testSize)

train_batch_count = int(math.ceil(trainSize / DATASET_BATCH_SIZE))
test_batch_count = int(math.ceil(testSize / DATASET_BATCH_SIZE))
validation_batch_count = int(math.ceil(validationSize / DATASET_BATCH_SIZE))


# Finding best parameters
# =======================================================

# if DO_COMPARISONS:
#     dims = [16, 32, 64, 128, 200, 256, 512]
#     categoricalHinge = []
#     categoricalAccuracy = []
#     fig = None
#
#     for dim in dims:
#         model = createModel(dim, 128, 32)
#         modelEvaluationResults = model.evaluate(testData, steps=test_batch_count)
#
#         categoricalHinge.append(modelEvaluationResults[2])
#         categoricalAccuracy.append(modelEvaluationResults[1])
#         fig = Plot.plotLosses(dims[0:len(categoricalAccuracy)], [[categoricalAccuracy, "categoricalAccuracy"], [categoricalHinge, "categoricalHinge"]], fig)

# class ErrorData:
#
#     def __init__(self, accurary, loss, dim1, dim2, dim3, steps):
#         self.accuracy = accurary
#         self.loss = loss
#         self.dim1 = dim1
#         self.dim2 = dim2
#         self.dim3 = dim3
#         self.steps = steps
#
# if DO_COMPARISONS:
#     dims = [8, 32, 128, 256]
#     steps = [1, 5, 25, 50]
#     categoricalHinge = []
#     categoricalAccuracy = []
#     fig = None
#
#     errors = []
#     bestAccuracy = ErrorData(0, 1, -1, -1, -1, -1)
#     bestLoss = ErrorData(0, 1, -1, -1, -1, -1)
#
#     import csv
#     csvfile = open('results.csv', 'w', newline='')
#
#     fieldnames = ['accuracy', 'loss', "dim1", "dim2", "dim3", "step"]
#     writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
#     writer.writeheader()
#
#     for dim1 in dims:
#         for dim2 in dims:
#             for dim3 in dims:
#                 for step in steps:
#                     print("\n==> Doing for: %d, %d, %d, %d\n" % (dim1, dim2, dim3, step))
#
#                     model = createModel(dim1, dim2, dim3, step)
#                     modelEvaluationResults = model.evaluate(testData, steps=test_batch_count)
#                     error = ErrorData(modelEvaluationResults[1], modelEvaluationResults[2], dim1, dim2, dim3, step)
#                     errors.append(error)
#
#                     writer.writerow({'accuracy' : error.accuracy, 'loss' : error.loss, 'dim1' : dim1, 'dim2' : dim2, 'dim3' : dim3, 'step' : step})
#
#                     if error.accuracy > bestAccuracy.accuracy:
#                         bestAccuracy = error
#
#                     if error.loss < bestLoss.loss:
#                         bestLoss = error
#
#     csvfile.close()
#     print("\nDone")


# Evaluation of a model
# ============================

modelCreator: ClassifierModel1Creator = ClassifierModel1Creator(
    voc_size=voc_size,
    theme_count=theme_count,
    theme_weight=themeWeight,
    trainData=trainData,
    train_batch_count=train_batch_count,
    validationData=validationData,
    validation_batch_count=validation_batch_count)

# For brands
#model = modelCreator.create_model(embedding_output_dim=128, intermediate_dim=256, last_dim=64, epochs=70)

# For device type
model = modelCreator.create_model(embedding_output_dim=128, intermediate_dim=512, last_dim=64, epochs=25)

print("\nPerform evaluation---")
modelEvaluationResults = model.evaluate(testData, steps=test_batch_count)

print("Evaluation results (loss, acc): ", modelEvaluationResults)


################################################################################################
# Manual Tests of the created model
################################################################################################

if POST_ALL_CLASSIFY:
    testPrint = ManualTestPrint(articles, themes, ARTICLE_MAX_WORD_COUNT, model, themeTokenizer)
    testPrint.print()

print("\nThemes idx:", themeTokenizer.word_index)


################################################################################################
# Classify unclassified articles
################################################################################################

# Helper


predictor = JsonArticlePredictor(model,
                                 supportedThemes,
                                 preprocessor,
                                 ARTICLE_MAX_WORD_COUNT,
                                 tokenizer,
                                 themeTokenizer,
                                 KEY_THEMES,
                                 KEY_VERIFIED_THEMES,
                                 KEY_PREDICTED_THEMES)

predictor.predict(json)

print("DONE!!!")
