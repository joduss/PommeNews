import unittest

from classifier.prediction.ArticlesPrediction import ArticlesPrediction
from classifier.preprocessing.article_theme_tokenizer import ArticleThemeTokenizer
from data_models.article import Article
from data_models.articles import Articles


class ArticlesPredictionTests(unittest.TestCase):

    def testApplyOnArticles(self):
        article2 = Article("2", "title", "summary", ["theme1", "theme2", "theme3"], ["other_theme"], [])
        article1 = Article("1", "title", "summary", ["theme1"], ["theme1", "old_prediction"], [])

        articles = Articles([article1, article2])

        theme_tokenizer = ArticleThemeTokenizer(articles)

        predictions = ArticlesPrediction(theme_tokenizer, articles)
        predictions.addPredictionsForArticle([0.1, 0.7, 0], article1.id)
        predictions.addPredictionsForArticle([0.4, 0.89, 0.99], article2.id)


        # Apply prediction with standard threshold
        predicted_articles = predictions.get_articles_with_predictions()
        predicted_articles_one = predicted_articles[0]
        predicted_articles_two = predicted_articles[1]

        self.assertEqual(1, len(predicted_articles_one.predicted_themes))
        self.assertFalse("theme1" in predicted_articles_one.predicted_themes)
        self.assertTrue("theme2" in predicted_articles_one.predicted_themes)
        self.assertFalse("theme3" in predicted_articles_one.predicted_themes)

        self.assertEqual(2, len(predicted_articles_two.predicted_themes))
        self.assertFalse("theme1" in predicted_articles_two.predicted_themes)
        self.assertTrue("theme2" in predicted_articles_two.predicted_themes)
        self.assertTrue("theme3" in predicted_articles_two.predicted_themes)


        # Apply prediction with custom threshold
        predicted_articles = predictions.get_articles_with_predictions(0.09)

        predicted_articles_one = predicted_articles[0]
        predicted_articles_two = predicted_articles[1]

        self.assertEqual(2, len(predicted_articles_one.predicted_themes))
        self.assertTrue("theme1" in predicted_articles_one.predicted_themes)
        self.assertTrue("theme2" in predicted_articles_one.predicted_themes)
        self.assertFalse("theme3" in predicted_articles_one.predicted_themes)

        self.assertEqual(3, len(predicted_articles_two.predicted_themes))
        self.assertTrue("theme1" in predicted_articles_two.predicted_themes)
        self.assertTrue("theme2" in predicted_articles_two.predicted_themes)
        self.assertTrue("theme3" in predicted_articles_two.predicted_themes)