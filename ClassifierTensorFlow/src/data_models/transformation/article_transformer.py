from typing import Dict

from data_models.article import Article


class ArticleTransformer:

    # JSON Keys
    # =========
    KEY_THEMES: str = "themes"
    KEY_VERIFIED_THEMES: str = "verifiedThemes"
    KEY_TITLE: str = "title"
    KEY_SUMMARY: str = "summary"
    KEY_PREDICTED_THEMES: str = "predictedThemes"

    @classmethod
    def transformToArticle(cls, articleJson):
        return Article(articleJson[cls.KEY_TITLE],
                       articleJson[cls.KEY_SUMMARY],
                       articleJson[cls.KEY_THEMES],
                       articleJson[cls.KEY_PREDICTED_THEMES],
                       articleJson[cls.KEY_VERIFIED_THEMES])

    @classmethod
    def transformToJson(cls, article: Article) -> Dict:
        json: Dict = {cls.KEY_THEMES: article.themes,
                      cls.KEY_VERIFIED_THEMES: article.verified_themes,
                      cls.KEY_TITLE: article.title,
                      cls.KEY_SUMMARY: article.summary,
                      cls.KEY_PREDICTED_THEMES: article.predicted_themes}

        return json
