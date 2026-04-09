def safe_get(obj, keys):
    current = obj
    for key in keys:
        if not isinstance(current, dict) or key not in current:
            return None
        current = current[key]
    return current


def override_value(global_settings, host_settings, path):
    if isinstance(path, str):
        keys = path.split(".")
    else:
        keys = path

    host_val = safe_get(host_settings or {}, keys)
    if host_val is not None:
        return host_val

    return safe_get(global_settings or {}, keys)


class FilterModule:
    @staticmethod
    def filters():
        return {
            "override_value": override_value,
        }
