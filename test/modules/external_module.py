VALUE = 99


def square(value):
    return value * value


def get_payload():
    return {
        "kind": "external",
        "tags": ["python", "module", "compat"],
        "nested": {"enabled": True, "version": 1},
    }


def describe(name="world", punctuation="!"):
    return f"Hello {name}{punctuation}"


def call_haxe_callback(cb, value):
    return cb(value, bonus=5)


def call_haxe_callback_twice(cb, value):
    return [cb(value), cb(value + 1)]


class Greeter:
    def __init__(self, prefix):
        self.prefix = prefix

    def greet(self, name):
        return f"{self.prefix}, {name}!"


class Point:
    def __init__(self, x, y, label="point"):
        self.x = x
        self.y = y
        self.label = label

    def as_tuple(self):
        return (self.x, self.y, self.label)


class FancyPoint(Point):
    pass


class DemoContext:
    def __init__(self, label):
        self.label = label
        self.events = []
        self.last_error = None

    def __enter__(self):
        self.events.append("enter")
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.events.append("exit")
        self.last_error = exc_type.__name__ if exc_type else None
        return False


class BrokenIter:
    def __iter__(self):
        return self

    def __next__(self):
        raise RuntimeError("broken iterator")
