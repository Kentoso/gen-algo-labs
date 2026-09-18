import math
import random
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

POPULATION_SIZE = 100
MAX_GENERATIONS = 500
TOURNAMENT_FRACTION = 0.05
CROSSOVER_PROBABILITY = 1.0
MUTATION_PROBABILITY = 0.10
ELITE_COUNT = 1
STAGNATION_LIMIT = 50
RANDOM_SEED = 43
LOG_INTERVAL = 10
CHART_PATH = Path(__file__).with_name("convergence.png")

DISTANCES = [
    [0, 34, 71, 28, 95, 46, 63, 19, 82, 57],
    [34, 0, 52, 88, 23, 76, 41, 65, 17, 93],
    [71, 52, 0, 36, 69, 14, 85, 47, 91, 25],
    [28, 88, 36, 0, 54, 79, 21, 97, 43, 60],
    [95, 23, 69, 54, 0, 32, 74, 16, 58, 81],
    [46, 76, 14, 79, 32, 0, 49, 90, 27, 66],
    [63, 41, 85, 21, 74, 49, 0, 38, 72, 13],
    [19, 65, 47, 97, 16, 90, 38, 0, 84, 55],
    [82, 17, 91, 43, 58, 27, 72, 84, 0, 31],
    [57, 93, 25, 60, 81, 66, 13, 55, 31, 0],
]


def route_length(route: list[int]) -> int:
    cycle = [0, *route, 0]
    return sum(DISTANCES[a][b] for a, b in zip(cycle, cycle[1:]))


def format_route(route: list[int]) -> str:
    return " -> ".join(map(str, [0, *route, 0]))


def select_parent(
    population: list[list[int]], rng: random.Random
) -> list[int]:
    size = math.ceil(len(population) * TOURNAMENT_FRACTION)
    return min(rng.sample(population, size), key=route_length)


def crossover(
    parent1: list[int], parent2: list[int], rng: random.Random
) -> tuple[list[int], list[int]]:
    child1, child2 = parent1.copy(), parent2.copy()
    if rng.random() < CROSSOVER_PROBABILITY:
        start, end = sorted(rng.sample(range(len(parent1)), 2))
        end += 1
        cities1 = set(parent1[start:end])
        cities2 = set(parent2[start:end])
        child1[start:end] = [city for city in parent2 if city in cities1]
        child2[start:end] = [city for city in parent1 if city in cities2]
    return child1, child2


def mutate(child: list[int], rng: random.Random) -> None:
    if rng.random() < MUTATION_PROBABILITY:
        a, b = rng.sample(range(len(child)), 2)
        child[a], child[b] = child[b], child[a]


def print_statistics(generation: int, population: list[list[int]]) -> None:
    scores = [route_length(route) for route in population]
    print(
        f"Generation {generation:4d} | Best: {min(scores):4d}"
        f" | Average: {sum(scores) / len(scores):8.2f}"
    )
    for rank, route in enumerate(sorted(population, key=route_length)[:5], 1):
        print(f"  #{rank} | Distance: {route_length(route):4d}"
              f" | {format_route(route)}")


def validate_settings() -> None:
    for name, value in (
        ("POPULATION_SIZE", POPULATION_SIZE),
        ("MAX_GENERATIONS", MAX_GENERATIONS),
        ("ELITE_COUNT", ELITE_COUNT),
        ("STAGNATION_LIMIT", STAGNATION_LIMIT),
        ("LOG_INTERVAL", LOG_INTERVAL),
    ):
        if type(value) is not int or value < 1:
            raise ValueError(f"{name} must be a positive integer")
    if POPULATION_SIZE < 2:
        raise ValueError("POPULATION_SIZE must be at least 2")
    if ELITE_COUNT >= POPULATION_SIZE:
        raise ValueError("ELITE_COUNT must be smaller than POPULATION_SIZE")
    if not 0 < TOURNAMENT_FRACTION <= 1:
        raise ValueError("TOURNAMENT_FRACTION must be in (0, 1]")
    for name, value in (
        ("CROSSOVER_PROBABILITY", CROSSOVER_PROBABILITY),
        ("MUTATION_PROBABILITY", MUTATION_PROBABILITY),
    ):
        if not 0 <= value <= 1:
            raise ValueError(f"{name} must be in [0, 1]")
    size = len(DISTANCES)
    if size < 3 or any(len(row) != size for row in DISTANCES):
        raise ValueError("DISTANCES must be square with at least 3 cities")
    for i in range(size):
        for j in range(size):
            value = DISTANCES[i][j]
            if type(value) is not int:
                raise ValueError("Distances must be integers")
            if (i == j and value != 0) or (i != j and value <= 0):
                raise ValueError("Use zero diagonal and positive distances")
            if value != DISTANCES[j][i]:
                raise ValueError("DISTANCES must be symmetric")


def save_chart(history: list[tuple[int, float]]) -> None:
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.plot([best for best, average in history], label="Best distance", linewidth=2)
    ax.plot([average for best, average in history], label="Average distance")
    ax.set(xlabel="Generation", ylabel="Distance (arbitrary units)",
           title="Lab 2: Genetic algorithm convergence")
    ax.grid(alpha=0.25)
    ax.legend()
    fig.tight_layout()
    fig.savefig(CHART_PATH, dpi=180)
    plt.close(fig)


def main() -> None:
    validate_settings()
    rng = random.Random(RANDOM_SEED)
    cities = list(range(1, len(DISTANCES)))
    population = [rng.sample(cities, len(cities)) for _ in range(POPULATION_SIZE)]
    best = min(population, key=route_length).copy()
    best_generation = 0
    stagnant_generations = 0
    history = []
    stop_reason = "generation limit reached"

    print("Lab 2: Travelling salesman problem with a genetic algorithm")
    print(f"Cities: {len(DISTANCES)} | Start/end city: 0 | Seed: {RANDOM_SEED}")
    print(f"Population: {POPULATION_SIZE} | Generation limit: {MAX_GENERATIONS}")
    print(f"Tournament: {TOURNAMENT_FRACTION:.0%}"
          f" ({math.ceil(POPULATION_SIZE * TOURNAMENT_FRACTION)} contestants)"
          f" | Elite: {ELITE_COUNT}")
    print(f"Segment reordering crossover: {CROSSOVER_PROBABILITY:.0%}")
    print(f"Swap mutation per child: {MUTATION_PROBABILITY:.0%}")
    print(f"Stagnation limit: {STAGNATION_LIMIT} | Log interval: {LOG_INTERVAL}")
    print("Distance matrix (arbitrary units):")
    print("     " + " ".join(f"{city:3d}" for city in range(len(DISTANCES))))
    for city, row in enumerate(DISTANCES):
        print(f"{city:3d}: " + " ".join(f"{distance:3d}" for distance in row))

    def record(population: list[list[int]]) -> None:
        scores = [route_length(route) for route in population]
        history.append((min(scores), sum(scores) / len(scores)))

    record(population)
    print_statistics(0, population)

    generation = 0
    for generation in range(1, MAX_GENERATIONS + 1):
        new_population = [best.copy() for _ in range(ELITE_COUNT)]
        while len(new_population) < POPULATION_SIZE:
            parents = [select_parent(population, rng) for _ in range(2)]
            for child in crossover(*parents, rng):
                if len(new_population) == POPULATION_SIZE:
                    break
                mutate(child, rng)
                new_population.append(child)
        population = new_population

        candidate = min(population, key=route_length)
        if route_length(candidate) < route_length(best):
            best = candidate.copy()
            best_generation = generation
            stagnant_generations = 0
        else:
            stagnant_generations += 1

        record(population)
        stagnated = stagnant_generations >= STAGNATION_LIMIT
        finished = stagnated or generation == MAX_GENERATIONS
        if generation % LOG_INTERVAL == 0 or finished:
            print_statistics(generation, population)
        if finished:
            if stagnated:
                stop_reason = "stagnation limit reached"
            break

    print(f"\nStopped after {generation} generations: {stop_reason}.")
    print(f"Best route: {format_route(best)}")
    print(f"Best distance: {route_length(best)}")
    print(f"First found at generation: {best_generation}")
    save_chart(history)
    print(f"Chart saved: {CHART_PATH.name}")


if __name__ == "__main__":
    main()
