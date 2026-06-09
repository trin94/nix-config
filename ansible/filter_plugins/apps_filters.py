def resolve_setting(global_settings, host_settings, key, default: bool):
    """
    Resolve a scalar setting with override logic:
    - If the key exists in workstation_settings, use it
    - Else if it exists in global_settings, use it
    - Else return default
    """
    if isinstance(host_settings, dict) and key in host_settings:
        return host_settings[key]
    if isinstance(global_settings, dict) and key in global_settings:
        return global_settings[key]
    return default


def merge_dict_lists_by_key(
    global_settings,
    host_settings,
    identifier,
    merge_key="name",
):
    def get_nested(settings, key_path):
        keys = key_path.split(".")
        for key in keys:
            if not isinstance(settings, dict) or key not in settings:
                return []
            settings = settings[key]
        return settings if isinstance(settings, list) else []

    def get_item_map(settings):
        items = get_nested(settings, identifier)
        return {item[merge_key]: item for item in items if isinstance(item, dict) and merge_key in item}

    global_items = get_item_map(global_settings)
    host_items = get_item_map(host_settings)

    merged = {**global_items, **host_items}
    return list(merged.values())


class FilterModule:
    @staticmethod
    def filters():
        return {
            "resolve_setting": resolve_setting,
            "merge_dict_lists_by_key": merge_dict_lists_by_key,
        }
