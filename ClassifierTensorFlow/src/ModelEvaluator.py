from dataclasses import dataclass

from Article import Article


@dataclass
class ModelEvaluator:

    predicted_articles = []

    def evaluate(self, predicted_articles: [Article], themes):
        self.predicted_articles = predicted_articles

        for theme in themes:
            self.evaluateTheme(theme)


    def evaluateTheme(self, theme: str):

        truePositive = 0
        trueNegative = 0
        falsePositive = 0
        falseNegative = 0

        for article in self.predicted_articles:
            if theme not in article.verified_themes:
                continue

            isOfTheme = theme in article.themes
            prediction = theme in article.predicted_themes

            if isOfTheme and prediction:
                truePositive += 1
            elif isOfTheme and not prediction:
                falseNegative += 1
            elif not isOfTheme and prediction:
                falsePositive += 1
            else:
                trueNegative += 1

        print("\n")
        print("Evaluation of predictions for theme \"{}\"".format(theme))
        print("------")

        print("TP = {}".format(truePositive))
        print("TN = {}".format(trueNegative))
        print("FP = {}".format(falsePositive))
        print("FN = {}".format(falseNegative))

        recall = 0
        precision = 0
        f_score = 0

        if (truePositive + falseNegative) > 0:
            recall = truePositive / (truePositive + falseNegative)

        if (truePositive + falsePositive) > 0:
            precision = truePositive / (truePositive + falsePositive)

        if (precision + recall) > 0:
            f_score = 2 * (precision * recall) / (precision + recall)

        print("Recall = {}".format(recall))
        print("Precision = {}".format(precision))
        print("F-scrore = {}".format(f_score))
