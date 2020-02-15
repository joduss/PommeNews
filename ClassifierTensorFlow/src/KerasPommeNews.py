from __future__ import absolute_import, division, print_function, unicode_literals

from typing import List

from keras_preprocessing.text import Tokenizer
from tensorflow.python.keras.preprocessing.text import Tokenizer
from tensorflow.python.keras .layers import *
from nltk.stem import WordNetLemmatizer


import tensorflow as tf
import numpy as np
import tensorflow.keras as keras
import math
import json as jsonModule
import FrenchStopwords

import Plot
from ArticlePreprocessor import ArticlePreprocessor
from ClassifierModel1Creator import ClassifierModel1Creator
from JsonArticlePredictor import JsonArticlePredictor

print("\n\n\n####################################\n####################################")

############################################
# Configuration
############################################

DO_COMPARISONS = False
POST_ALL_CLASSIFY = True
POST_CLASSIFY_NO_CLASSIFIED = True

DATASET_BATCH_SIZE = 30
ARTICLE_MAX_WORD_COUNT = 200
TRAIN_RATIO = 0.65
VALIDATION_RATIO = 0.17 # TEST if 1 - TRAIN_RATIO - VALIDATION_RATIO
VOCABULARY_MAX_SIZE = 50000 # not used for now!

LANG = "french"

OUT_FILE = "~/out.json"

file = open("articles_fr.json", "r")
supportedThemes: List[str] = ["google", "apple", "microsoft", "samsung", "amazon", "facebook", "netflix", "spotify"]

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
all_orig_articles: List[str] = [jsonObject["title"] + ". " + jsonObject["summary"] for jsonObject in json if len(jsonObject["themes"]) > 0]
all_themes: List[List[str]] = [jsonObject["themes"] for jsonObject in json if len(jsonObject["themes"]) > 0]


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
    if len(filteredThemes) > 0:
        themes.append(filteredThemes)
        articles.append(articlesInFiltering[idx])
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
    themeWeight[i] = 1 / (themeWeight[i] / largestThemeArticleCount)


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

model = modelCreator.create_model(embedding_output_dim=128, intermediate_dim=256, last_dim=64, epochs=8)

print("\nPerform evaluation---")
modelEvaluationResults = model.evaluate(testData, steps=test_batch_count)

print("Evaluation results (loss, acc): ", modelEvaluationResults)


################################################################################################
# Manual Tests of the created model
################################################################################################

# Utility functions
# ============================


def doPrediction(text):
    text = preprocessor.process_article(text)
    vector = tokenizer.texts_to_sequences([text])
    vector = keras.preprocessing.sequence.pad_sequences(vector,
                                                        value=0,
                                                        padding='post',
                                                        maxlen=ARTICLE_MAX_WORD_COUNT)

    return model.predict(vector)


def predictionToHumanReadable(text):
    predictions = doPrediction(text)[0]
    idxWord = themeTokenizer.index_word
    return " - ".join("{}({})".format(idxWord[idx], prediction) for idx, prediction in enumerate(predictions, start=1))



# Manual test.
# ============================


print("\n\n--- Manual tests\n===")

print("Article 1: (Apple, ios, beta)", predictionToHumanReadable("Apple propose les bêtas 2 pour iOS13.2, iPadOS 13.2 et tvOS 13.2 et watchOS 6.1 bêta 3. Apple propose ce soir la deuxième bêta d'iOS 13.2, iPadOS 13.2 et tvOS 13.2. A noter que les versions définitives d'iOS 13.1.2 et iPadOS 13.1.2 ont été dévoilées le 30 septembre dernier et qu'elle amenaient leurs lots de corrections de bugs, notamment au niveau du Bluetooth, de l'appareil photo, d'iCloud, etc.Avec la bêta 1 d'iOS 13.2, dévoilée la semaine dernière, Apple a intégré la fonctionnalité « Deep Fusion » présentée durant la keynote -que nous avons testée ci-dessous. Il s'agit d'une fonctionnalité qui permet d'améliorer les prises de vues photographiques grâce au Neural Engine des nouveaux iPhone. En complément, Apple propose également la bêta 3 de watchOS 6.1."))

print("Article 2 (Apple, appleWatch):", predictionToHumanReadable("Apple supprime plusieurs dizaines de bracelets Apple Watch. À quelques semaines du keynote de septembre et de la présentation de nouvelles Apple Watch et probablement de nouveaux accessoires pour les accompagner, Apple fait le ménage sur sa boutique dans la section des bracelets. Comme le rapporte Mac Rumors, le constructeur a supprimé 14 références de sa boutique et une vingtaine de modèles sont encore listés, mais ils sont indiqués « épuisés ». \nLe bracelet Pride nylon fait partie des modèles épuisés en France également.\n\nL’état des stocks n’est pas identique en France et aux États-Unis où le site dresse sa liste exhaustive. Néanmoins, Apple a certainement prévu d’arrêter certains coloris de bracelet comme elle le fait à chaque renouvellement de gamme et le constructeur vide certainement ses stocks. Si un modèle vous donnait envie, ne trainez pas pour le commander, s’il est encore en stock. Ou alors attendez le mois de septembre pour découvrir la gamme automnale."))
print("Article 3 (Google): ", predictionToHumanReadable("Google revoit entièrement l'interface de Wear OS. Le système d’exploitation de Google destiné aux montres connectées évolue encore. Après un changement de nom en début d’année, c’est l’interface de Wear OS qui est maintenant complètement modifiée. \n\nTrois avantages sont mis en avant par Google, à commencer par un accès simplifié aux notifications, d’un balayage du bas de l’écran vers le haut, et aux raccourcis (mode avion, Google Pay, ne pas déranger…), d’un geste du haut vers le bas.\nLa nouvelle interface de Wear OS\n\nGoogle Assistant s’intègre mieux à Wear OS : glissez vers la droite pour voir toutes les suggestions et tous les rappels de l’assistant. C’est similaire au cadran Siri de l’Apple Watch, si ce n’est que ce n’est pas un cadran mais une vue à part entière.\nLes cinq écrans de Wear OS. Montage Ars Technica.\n\nDe la même manière, Google Fit, l’application revue la semaine dernière qui permet de suivre son activité physique, est en bonne place à droite du cadran.\n\nLa mise à jour sera déployée à partir du mois prochain sur les montres Wear OS. Google pourrait présenter cet automne sa propre famille de montres connectées."))
print("Article 4 (Google)", predictionToHumanReadable("Du neuf chez les Google Glass : de la musique, des économies, et de nouveaux Explorers. Cela fait un bon moment que nous ne vous avions pas parlé des Google Glass. Que se passe-t-il du côté de Mountain View ? Quelle sont les nouveautés ajoutées aux lunettes connectées du géant californien ? D’une compatibilité avec Google Play Music à la seconde vague d’inscriptions pour le programme Explorer, en passant pour les centaines de millions de dollars que les Glass vont pouvoir faire économiser aux entreprises, voici les principales nouveautés à ne pas rater au sujet des lunettes connectées de Google."))
print("Article 5 (Google)", predictionToHumanReadable("L'application iGeneration débarque sur Android. Vous ne rêvez pas, ce n'est pas non plus un poisson d'avril en avance… Nous sommes fiers de vous annoncer le lancement de notre application iGeneration sur Android !"))
print("Article 6 (Apple)", predictionToHumanReadable("Apple interdirait les contenus TV+ déplaisants pour la Chine. Apple est actuellement sous pression de la Chine, notamment vis-à-vis des problématiques autour de Hong Kong qui oblige Tim Cook à venir supprimer des applications utilisées par les manifestants. La polémique encore risque d'enfler en apprenant aujourd'hui qu'Eddy Cue en personne aurait demandé aux créateurs de contenus pour le futur service AppleTV+ d'éviter les contenus « sensibles » qui pourrait provoquer la colère du régime chinois. La pratique ne semble pas nouvelle pour Apple, ni pour l'industrie hollywoodienne en général, ceci afin de continuer à profiter de ce marché gigantesque, mais aussi très contrôlé et peu ouvert à l'auto-critique. La Pomme a d'ailleurs toutes les peines du monde à imposer là-bas ses boutiques culturelles - les iTunes Movie et iBooks stores ont été fermés 6 mois après leur sortie en Chine."))
print("Article 7 (Apple, Google)", predictionToHumanReadable("Google Maps s’affiche dans CarPlay en bêta. Après Waze, c’est au tour de Google Maps de s’adapter à CarPlay. Les testeurs du service de cartographie du moteur de recherche ont maintenant accès à une nouvelle version de l’application compatible avec le système d’affichage déporté d’iOS. \n\n\n\n\n\n\n\nD’après un des testeurs qui partage un paquet de captures d’écran, « l’expérience » Google Maps est proche de ce qu’on connait ailleurs. Les informations, les POI ainsi que les cartes proviennent évidemment des bases de données de Google. On ignore en revanche quand l’application sera disponible — la version finale d’iOS 12 sera disponible lundi prochain."))
print("article 8 (Microsoft, Samsung)", predictionToHumanReadable("Microsoft Suface Duo vs. Samsung Galaxy Fold : qui est le champion de la productivité ? Microsoft a frappé un grand coup en annonçant son Surface Duo, un appareil Android à double affichage qui devrait être lancé dans environ un an. Celui-ci se fonde sur un concept similaire au principe du Galaxy Fold de Samsung, que ce soit via la prise en charge sous Android ou l'aspect pliable. Avec cet appareil, la firme de Redmond pourra-t-elle faire de l'ombre au flagship du constructeur coréen ? Réponse ci-dessous."))
print("Article 9 (Facebook)", predictionToHumanReadable("Facebook Messenger : petits changements entre amis, et bientôt un mode sombre"))
print("Article 10 (Apple, ipad, tablet, rumor", predictionToHumanReadable("iPad Pro 2018 : une fuite en 3D annonce une tablette avec Face ID"))


# print("\n-----\n")
# print("articles[16]" + "themes: " + str(themes[16]) + " => ", predictionToHumanReadable(articles[16]), articles[16])
# print("\n-----\n")
# print("articles[160]" + "themes: " + str(themes[160]) + " => ", predictionToHumanReadable(articles[160]), articles[160])
# print("\n-----\n")
# print("articles[111]" + "themes: " + str(themes[111]) + " => ", predictionToHumanReadable(articles[111]), articles[111])
# print("\n-----\n")
# print("articles[66]" + "themes: " + str(themes[66]) + " => ", predictionToHumanReadable(articles[16]), articles[66])

if POST_ALL_CLASSIFY:
    idx = 0
    for article in articles:
        print("article ", idx, " themes: ", themes[idx], " # predicted ===> ", predictionToHumanReadable(articles[idx]), " ||||| original article: ", articles[idx])
        idx = idx + 1

    print("")
    print("what is the galaxy s3?", predictionToHumanReadable("what is the galaxy s3?"))
    print("I bought 2 ipad in the last year. I am very happy with them, I could get rid of my old computer", predictionToHumanReadable("I bought 2 ipad in the last year. I am very happy with them, I could get rid of my old computer"))
    print("both apple and samsung are active in the it domain", predictionToHumanReadable("both apple and samsung are active in the it domain"))
    print()
    print("apple ipad air 2", predictionToHumanReadable("apple ipad air 2"))
    print("iphone 4s", predictionToHumanReadable("iphone 4s"))
    print("galaxy", predictionToHumanReadable("galaxy"))
    print("galaxy tab", predictionToHumanReadable("galaxy tab"))
    print("ania: \That fucking ipad.\"", predictionToHumanReadable("That fucking ipad."))
    print("surface special: ", predictionToHumanReadable("surface special"))
    print("surface go: ", predictionToHumanReadable("surface go"))
    print("microsoft et apple: ", predictionToHumanReadable("microsoft et apple."))
    print("Je suis sur la lune: ", predictionToHumanReadable("Je suis sur la lune"))

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
