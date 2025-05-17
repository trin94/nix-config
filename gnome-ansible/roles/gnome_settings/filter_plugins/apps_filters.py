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


def merge_apps_by_name(global_settings, host_settings):
    """
    Merge workstation_settings.apps with global_workstation_settings.apps,
    overriding by 'name'. Host settings take priority.

    Returns a list of unique app dicts.
    """

    def get_app_map(settings):
        if not isinstance(settings, dict):
            return {}
        apps = settings.get("apps", [])
        return {
            app["name"]: app for app in apps if isinstance(app, dict) and "name" in app
        }

    global_apps = get_app_map(global_settings)
    host_apps = get_app_map(host_settings)

    # Host overrides global
    merged = {**global_apps, **host_apps}

    # Return as a list
    return list(merged.values())


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


class FilterModule:
    @staticmethod
    def filters():
        return {
            "is_app_present": is_app_present,
            "merge_apps_by_name": merge_apps_by_name,
            "resolve_setting": resolve_setting,
        }
