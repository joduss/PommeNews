import json as jsonModule
from typing import List

import tensorflow as tf
import tensorflow.keras as keras
import ArticlePreprocessor
from tensorflow.python.keras.preprocessing.text import Tokenizer

class JsonArticlePredictor:
    '''
    Do theme predictions for articles.
    '''

    CLASSIFIER_THRESHOLD: float = 0.5

    def __init__(self,
                 classifierModel: tf.keras.models.Model,
                 supportedThemes: List[str],
                 preprocessor: ArticlePreprocessor,
                 maxArticleLength: int,
                 articleTokenizer: Tokenizer,
                 themeTokenizer: Tokenizer,
                 KEY_THEMES: str,
                 KEY_VERIFIED_THEMES: str,
                 KEY_PREDICTED_THEMES:str):
        self.classifierModel = classifierModel
        self.supportedThemes = supportedThemes
        self.preprocessor = preprocessor
        self.maxArticleLength = maxArticleLength
        self.themeTokenizer = themeTokenizer
        self.articleTokenizer = articleTokenizer
        self.KEY_THEMES = KEY_THEMES
        self.KEY_VERIFIED_THEMES = KEY_VERIFIED_THEMES
        self.KEY_PREDICTED_THEMES = KEY_PREDICTED_THEMES


    def predict(self, json):

        numArticleJson = len(json)
        numProcessedArticle = 0
        for articleJson in json:
            articleThemes = articleJson[self.KEY_THEMES]
            articleVerifiedThemes = articleJson[self.KEY_VERIFIED_THEMES]


            if self.__requireClassification(self.supportedThemes, articleJson):

                # classify here
                unverifiedThemes = self.__findUnverifiedThemes(self.supportedThemes, articleVerifiedThemes)
                if len(unverifiedThemes) == 0:
                    continue
                predictedThemes = self.__doPrediction(articleJson["title"] + ". " + articleJson["summary"], unverifiedThemes)
                articleJson[self.KEY_PREDICTED_THEMES] = predictedThemes

            numProcessedArticle = numProcessedArticle + 1
            print("Progress: " + str(numProcessedArticle) +  "/"  + str(numArticleJson))

        with open('predictions.json', 'w') as outfile:
            jsonModule.dump(json, outfile)


    def __doPrediction(self, text, themesToClassify):
        text = self.preprocessor.process_article(text)
        vector = self.articleTokenizer.texts_to_sequences([text])
        vector = keras.preprocessing.sequence.pad_sequences(vector,
                                                            value=0,
                                                            padding='post',
                                                            maxlen=self.maxArticleLength)

        predictions = self.classifierModel.predict(vector)

        themesPredictions = []
        for themeToClassify in themesToClassify:

            idxTheme = self.themeTokenizer.word_index[themeToClassify] - 1

            if predictions[0][idxTheme] > self.CLASSIFIER_THRESHOLD:
                themesPredictions.append(themeToClassify)

        return themesPredictions


    def __requireClassification(self, supportedThemes, articleJson):
        """
        Check if the article has some themes that are not verified.
        :param articleJson:
        :return:
        """
        articleThemes = articleJson[self.KEY_THEMES]
        articleVerifiedThemesLocal = articleJson[self.KEY_VERIFIED_THEMES]

        for supportedTheme in supportedThemes:
            if supportedTheme not in articleVerifiedThemesLocal:
                return True

        return False


    def __findUnverifiedThemes(self, supportedThemes, articleVerifiedThemes):
        unverifiedThemesLocal = []
        for supportedTheme in supportedThemes:
            if supportedTheme not in articleVerifiedThemes:
                unverifiedThemesLocal.append(supportedTheme)
        return unverifiedThemesLocal