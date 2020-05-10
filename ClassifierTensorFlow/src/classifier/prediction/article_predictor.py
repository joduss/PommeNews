import json as jsonModule
from typing import List

import tensorflow as tf
import tensorflow.keras as keras

from classifier.preprocessing.article_text_tokenizer import ArticleTextTokenizer
from classifier.preprocessing.article_theme_tokenizer import ArticleThemeTokenizer
from classifier.preprocessing.interface_article_preprocessor import IArticlePreprocessor
from data_models.article import Article
from data_models.articles import Articles
from data_models.transformation.article_transformer import ArticleTransformer


class ArticlePredictor:
    """
    Do theme predictions for data_models.
    """

    CLASSIFIER_THRESHOLD: float = 0.5

    limit_predictions: int = None

    def __init__(self,
                 classifier_model: tf.keras.models.Model,
                 supported_themes: List[str],
                 preprocessor: IArticlePreprocessor,
                 article_tokenizer: ArticleTextTokenizer,
                 theme_tokenizer: ArticleThemeTokenizer):
        self.classifier_model: tf.keras.models.Model = classifier_model
        self.supported_themes: List[str] = supported_themes
        self.preprocessor: IArticlePreprocessor = preprocessor
        self.theme_tokenizer: ArticleThemeTokenizer = theme_tokenizer
        self.article_tokenizer: ArticleTextTokenizer = article_tokenizer


    def predict(self, articles: Articles, article_preprocessed: bool = False):

        if self.limit_predictions is not None:
            articles.items = articles.items[0:self.limit_predictions]

        num_article_json = articles.count()
        num_processed_article = 0

        article: Article
        for article in articles.items:

            if article_preprocessed is False:
                article.predicted_themes = self.__predict_article(article, self.supported_themes)
            else:
                article.predicted_themes = self.__predict_preprocessed_article(article, self.supported_themes)

            num_processed_article += 1

            if num_processed_article % 10 == 0:
                print("Progress: " + str(num_processed_article) + "/" + str(num_article_json))

        with open('predictions.json', 'w', encoding="utf-8") as outfile:
            jsonModule.dump([ArticleTransformer.transformToJson(article) for article in articles], outfile, indent=4)


    def __predict_article(self, article: Article, themes_to_classify: List[str]):
        """
        Run prediction for an article that is not preprocessed yet. (Will be in this method!)
        :param article:
        :param themes_to_classify:
        :return:
        """
        article_processed = self.preprocessor.process_article(article)
        vector = self.article_tokenizer.transform_to_sequence(article_processed)

        predictions = self.classifier_model.predict(vector)

        themes_predictions = []
        for theme_to_classify in themes_to_classify:

            idx_theme = self.theme_tokenizer.tokenizer.word_index[theme_to_classify] - 1

            if predictions[0][idx_theme] > self.CLASSIFIER_THRESHOLD:
                themes_predictions.append(theme_to_classify)

        return themes_predictions


    def __predict_preprocessed_article(self, preprocessed_article: Article, themes_to_classify: List[str]):
        """
        Run prediction for an article that is has already been preprocessed. (Will be processed)
        :param preprocessed_article:
        :param themes_to_classify:
        :return:
        """
        vector = self.article_tokenizer.transform_to_sequence(preprocessed_article)

        predictions = self.classifier_model.predict(vector)

        themes_predictions = []
        for themeToClassify in themes_to_classify:

            idx_theme = self.theme_tokenizer.indexOfTheme(themeToClassify)

            if predictions[0][idx_theme] > self.CLASSIFIER_THRESHOLD:
                themes_predictions.append(themeToClassify)

        return themes_predictions
