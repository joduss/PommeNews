from dataclasses import dataclass

from data_models.article import Article


@dataclass
class ModelEvaluator:

    predicted_articles = []

    def evaluate(self, predicted_articles: [Article], themes):
        self.predicted_articles = predicted_articles

        for theme in themes:
            self.evaluateTheme(theme)


    def evaluateTheme(self, theme: str):

        true_positive = 0
        true_negative = 0
        false_positive = 0
        false_negative = 0

        for article in self.predicted_articles:
            if theme not in article.verified_themes:
                continue

            is_of_theme = theme in article.themes
            prediction = theme in article.predicted_themes

            if is_of_theme and prediction:
                true_positive += 1
            elif is_of_theme and not prediction:
                false_negative += 1
            elif not is_of_theme and prediction:
                false_positive += 1
            else:
                true_negative += 1

        print("\n")
        print("Evaluation of predictions for theme \"{}\"".format(theme))
        print("------")

        print("TP = {}".format(true_positive))
        print("TN = {}".format(true_negative))
        print("FP = {}".format(false_positive))
        print("FN = {}".format(false_negative))

        recall = 0
        precision = 0
        f_score = 0

        if (true_positive + false_negative) > 0:
            recall = true_positive / (true_positive + false_negative)

        if (true_positive + false_positive) > 0:
            precision = true_positive / (true_positive + false_positive)

        if (precision + recall) > 0:
            f_score = 2 * (precision * recall) / (precision + recall)

        print("Recall = {}".format(recall))
        print("Precision = {}".format(precision))
        print("F-scrore = {}".format(f_score))
