import json as jsonModule
from typing import List

import tensorflow as tf
import tensorflow.keras as keras
from tensorflow.python.keras.preprocessing.text import Tokenizer

from classifier.preprocessing.article_preprocessor import ArticlePreprocessor
from data_models.article import Article
from data_models.articles import Articles
from data_models.transformation.article_transformer import ArticleTransformer


class ArticlePredictor:
    '''
    Do theme predictions for data_models.
    '''

    CLASSIFIER_THRESHOLD: float = 0.5

    limit_predictions: int = None

    def __init__(self,
                 classifierModel: tf.keras.models.Model,
                 supportedThemes: List[str],
                 preprocessor: ArticlePreprocessor,
                 maxArticleLength: int,
                 articleTokenizer: Tokenizer,
                 themeTokenizer: Tokenizer):
        self.classifier_model: tf.keras.models.Model = classifierModel
        self.supported_themes: List[str] = supportedThemes
        self.preprocessor: ArticlePreprocessor = preprocessor
        self.max_article_length: int = maxArticleLength
        self.theme_tokenizer: Tokenizer = themeTokenizer
        self.article_tokenizer: Tokenizer = articleTokenizer


    def predict(self, articles: Articles):

        if self.limit_predictions is not None:
            articles.items = articles.items[0:self.limit_predictions]

        numArticleJson = articles.count()
        num_processed_article = 0

        article: Article
        for article in articles.items:

            article.predicted_themes = self.__do_prediction(article, self.supported_themes)

            num_processed_article += 1

            if num_processed_article % 10 == 0:
                print("Progress: " + str(num_processed_article) +  "/"  + str(numArticleJson))

        with open('predictions.json', 'w', encoding="utf-8") as outfile:
            jsonModule.dump([ArticleTransformer.transformToJson(article) for article in articles], outfile, indent=4)


    def __do_prediction(self, article: Article, themesToClassify: List[str]):
        article_processed = self.preprocessor.process_article(article)
        vector = self.article_tokenizer.texts_to_sequences([article_processed.title_and_summary()])
        vector = keras.preprocessing.sequence.pad_sequences(vector,
                                                            value=0,
                                                            padding='post',
                                                            maxlen=self.max_article_length)

        predictions = self.classifier_model.predict(vector)

        themesPredictions = []
        for themeToClassify in themesToClassify:

            idxTheme = self.theme_tokenizer.word_index[themeToClassify] - 1

            if predictions[0][idxTheme] > self.CLASSIFIER_THRESHOLD:
                themesPredictions.append(themeToClassify)

        return themesPredictions
