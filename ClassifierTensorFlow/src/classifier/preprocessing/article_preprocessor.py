from typing import List

import spacy
from pathos.multiprocessing import ProcessingPool as Pool

from data_models.article import Article

spacier = spacy.load("fr_core_news_sm")

import nltk
from nltk.corpus import stopwords

nltk.download('stopwords')
nltk.download('punkt')


class ArticlePreprocessor:
    """
    Preprocessor cleaning the article / data_models
    """

    language: str = ''

    def __init__(self, language: str):
        self.language = language
        self.stop_words = set(stopwords.words(self.language))

    def process_articles(self, articles: List[Article]) -> List[Article]:
        """
        Remove stopwords and do lemmatization on each article, for the specified language.
        :param articles: data_models to process
        :param LANG: language of the data_models
        :return: processed data_models
        """

        p = Pool(8)

        return p.map(self.process_article, articles)


    def process_article(self, article: Article) -> Article:
        """
        Remove stopwords and do lemmatization on an article, for the specified language.
        :param article:
        """

        article_copy = article.copy()

        article_copy.title = self.process_text(article.title)
        article_copy.summary = self.process_text(article.summary)

        return article_copy

    def process_text(self, text: str) -> str:
        """
        Remove stopwords and do lemmatization on a text, for the specified language
        :param text: article to process
        :param LANG: language of the article
        :return: processed article
        """

        text_tokenized = nltk.tokenize.word_tokenize(text, self.language)
        text_tokenized = [w for w in text_tokenized if not w in self.stop_words]
        text_processed = " ".join(text_tokenized)

        # lemmatizing the data_models return a list of lemmas.
        lemmas = spacier(text_processed)
        lemmas = [lemma.lemma_ for lemma in lemmas if lemma.lemma_ not in ["'", "'", "’"]]

        return " ".join(lemmas)
