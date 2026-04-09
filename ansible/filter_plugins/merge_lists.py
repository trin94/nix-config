def safe_get_list(obj, keys):
    current = obj
    for key in keys:
        if not isinstance(current, dict) or key not in current:
            return []
        current = current[key]
    return current if isinstance(current, list) else []


def merge_lists(global_settings, host_settings, path):
    if isinstance(path, str):
        keys = path.split(".")
    else:
        keys = path
    return safe_get_list(global_settings, keys) + safe_get_list(host_settings, keys)


class FilterModule:
    @staticmethod
    def filters():
        return {
            "merge_lists": merge_lists,
        }
