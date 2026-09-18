import json
from itertools import permutations
from pathlib import Path

from main import DISTANCES

OUTPUT_PATH = Path(__file__).with_name("verification.json")


def main() -> None:
    size = len(DISTANCES)
    if size < 3 or any(len(row) != size for row in DISTANCES):
        raise ValueError("DISTANCES must be square with at least 3 cities")
    for i, row in enumerate(DISTANCES):
        for j, value in enumerate(row):
            if type(value) is not int:
                raise ValueError("Distances must be integers")
            if (i == j and value != 0) or (i != j and value <= 0):
                raise ValueError("Use zero diagonal and positive distances")
            if value != DISTANCES[j][i]:
                raise ValueError("DISTANCES must be symmetric")

    best_route = None
    best_distance = None
    count = 0
    for route in permutations(range(1, size)):
        cycle = [0, *route, 0]
        distance = sum(
            DISTANCES[cycle[i]][cycle[i + 1]] for i in range(size)
        )
        count += 1
        if best_distance is None or distance < best_distance:
            best_distance = distance
            best_route = cycle

    result = {
        "method": "Exhaustive enumeration with city 0 fixed",
        "permutations": count,
        "matrix": DISTANCES,
        "optimal_route": best_route,
        "optimal_distance": best_distance,
    }
    OUTPUT_PATH.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"Checked permutations: {count}")
    print("Optimal route: " + " -> ".join(map(str, best_route)))
    print(f"Optimal distance: {best_distance}")
    print(f"Verification saved: {OUTPUT_PATH.name}")


if __name__ == "__main__":
    main()
