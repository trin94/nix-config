def is_app_present(global_settings, host_settings, app_name):
    """
    Determines whether an app should be installed (state: present),
    giving priority to host-specific settings.

    Priority order:
      1. workstation_settings.apps overrides global
      2. If not defined in workstation_settings, fall back to global
    """

    def find_app_state(settings):
        """Return 'present', 'absent', or None if not found."""
        if not isinstance(settings, dict):
            return None
        apps = settings.get("apps", [])
        if not isinstance(apps, list):
            return None
        for app in apps:
            if isinstance(app, dict) and app.get("name") == app_name:
                return app.get("state")
        return None

    # Check host-specific setting
    host_state = find_app_state(host_settings)
    if host_state == "present":
        return True
    if host_state == "absent":
        return False

    # Fallback to global if not defined in host
    return find_app_state(global_settings) == "present"


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


def merge_dict_lists_by_key(global_settings, host_settings, identifier, merge_key="name"):
    def get_nested(settings, key_path):
        keys = key_path.split(".")
        for key in keys:
            if not isinstance(settings, dict) or key not in settings:
                return []
            settings = settings[key]
        return settings if isinstance(settings, list) else []

    def get_item_map(settings):
        items = get_nested(settings, identifier)
        return {
            item[merge_key]: item
            for item in items
            if isinstance(item, dict) and merge_key in item
        }

    global_items = get_item_map(global_settings)
    host_items = get_item_map(host_settings)

    merged = {**global_items, **host_items}
    return list(merged.values())


class FilterModule:
    @staticmethod
    def filters():
        return {
            "is_app_present": is_app_present,
            "resolve_setting": resolve_setting,
            "merge_dict_lists_by_key": merge_dict_lists_by_key,
        }
