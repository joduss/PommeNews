from __future__ import annotations

import random
from typing import Dict, List, TextIO

import json as jsonModule

from data_models.article import Article
from data_models.transformation.article_transformer import ArticleTransformer
from utilities.utility import intersection


class Articles:

    jsonObject: Dict
    items: List[Article]

    def __init__(self, articles: List[Article] = None, article: Article = None):
        if articles is not None and isinstance(articles, list):
            self.items = articles
        elif article is not None and isinstance(article, Article):
            self.items = [article]
        else:
            raise Exception("article or articles must be provided. NOT BOTH either!")

    def __iter__(self):
        return self.items.__iter__()



    @staticmethod
    def from_file(path: str, limit: int = None) -> Articles:
        file: TextIO = open(path, "r", encoding="utf-8")
        return Articles.load_articles(file, limit)

    @staticmethod
    def load_articles(file: TextIO, limit: int = None) -> Articles:
        """
            Creates an object data_models from a json file containing data_models.
        :param file:
        :param limit:
        """
        json = jsonModule.loads(file.read())

        if limit is not None:
            json = json[0:limit]

        articles: List[Article] = []

        for jsonArticle in json:
            articles.append(ArticleTransformer.transformToArticle(jsonArticle))

        return Articles(articles)

    def save(self, filepath: str):
        with open(filepath, 'w', encoding="utf-8") as outfile:
            jsonModule.dump([ArticleTransformer.transformToJson(article) for article in self.items], outfile, indent=4)


    def articles_with_theme(self, theme: str) -> Articles:
        return Articles(list(filter(lambda article: theme in article.themes, self.copyEachArticle())))


    def articles_with_all_verified_themes(self, themes: List[str]) -> Articles:
        """
        Returns a new Articles instance containing articles whose verified themes are containing a given list of themes.
        :param themes:
        :return:
        """
        return Articles(
            list(
                filter(
                    lambda article: (len(intersection(themes, article.verified_themes)) == len(themes)),
                    self.copyEachArticle()
                )
            )
        )


    def themes(self) -> List[str]:
        return list(
            map(lambda article: article.themes, self.items)
        )


    def title_and_summary(self) -> List[str]:
        return list(
            map(lambda article: article.title_and_summary(), self.items)
        )


    def count(self) -> int:
        return len(self.items)


    def copyEachArticle(self) -> List[Article]:
        return list(
            map(lambda article: article.copy(), self.items)
        )


    def shuffle(self):
        random.shuffle(self.items)