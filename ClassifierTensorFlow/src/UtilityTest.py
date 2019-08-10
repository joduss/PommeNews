import unittest
from src import utility


class MyTestCase(unittest.TestCase):
    def test_something(self):
        themes = [["asd", "asdf"], [], ["sdf"]]

        self.assertEqual(2, len(utility.remove_empty_lists(themes)))


if __name__ == '__main__':
    unittest.main()
