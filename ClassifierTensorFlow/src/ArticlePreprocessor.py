from typing import List
from pathos.multiprocessing import ProcessingPool as Pool
import spacy
import numpy as np
spacier = spacy.load("fr_core_news_sm")

import nltk
from nltk.corpus import stopwords
nltk.download('stopwords')
nltk.download('punkt')


class ArticlePreprocessor:
    '''
    Preprocessor cleaning the article / articles
    '''

    language : str = ''

    def __init__(self, language):
        self.language = language
        self.stop_words = set(stopwords.words(self.language))


    def process_articles(self, articles):
        '''
        Remove stopwords and do lemmatization on each article, for the specified language
        :param articles: articles to process
        :param LANG: language of the articles
        :return: processed articles
        '''

        processedArticles = articles

        p = Pool(8)

        processedArticles = p.map(self.process_article, processedArticles)

        # for i in range(0, len(articles)):
        #     processedArticle = self.process_article(articles[i])
        #     processedArticles.append(processedArticle)

        return processedArticles


    def process_article(self, article: str):
        '''
        Remove stopwords and do lemmatization on an article, for the specified language
        :param article: article to process
        :param LANG: language of the article
        :return: processed article
        '''


        article_tokenized = nltk.tokenize.word_tokenize(article, self.language)
        article_tokenized = [w for w in article_tokenized if not w in self.stop_words]
        article_processed = " ".join(article_tokenized)

        # lemmatizing the articles return a list of lemmas.
        lemmas = spacier(article_processed)

        return " ".join([token.lemma_ for token in lemmas])