from typing import List


# Removes the enclosed lists that are empty.
def remove_empty_lists(list_of_lists: List[List[str]]):
    return list(filter(lambda list: len(list) > 0, list_of_lists))
