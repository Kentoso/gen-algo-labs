import math
import random

POPULATION_SIZE = 100
MAX_GENERATIONS = 500
TOURNAMENT_FRACTION = 0.05
CROSSOVER_PROBABILITY = 1.0
MUTATION_PROBABILITY = 0.05
ELITE_COUNT = 1
STAGNATION_LIMIT = 5
RANDOM_SEED = 43
LOG_INTERVAL = 1

BITS_PER_VARIABLE = 4
CHROMOSOME_LENGTH = 16


def decode(chromosome: list[int]) -> tuple[int, int, int, int]:
    values = []
    for start in range(0, CHROMOSOME_LENGTH, BITS_PER_VARIABLE):
        value = 0
        for bit in chromosome[start : start + BITS_PER_VARIABLE]:
            value = value * 2 + bit
        values.append(value)
    w, x, y, z = values
    return w, x, y, z


def format_chromosome(chromosome: list[int]) -> str:
    return " | ".join(
        "".join(map(str, chromosome[start : start + BITS_PER_VARIABLE]))
        for start in range(0, CHROMOSOME_LENGTH, BITS_PER_VARIABLE)
    )


def fitness(chromosome: list[int]) -> int:
    w, x, y, z = decode(chromosome)
    return w**3 + x**2 - y**2 - z**2 + 2*y*z - 3*w*x + w*z - x*y + 2


def select_parent(
    population: list[list[int]], rng: random.Random
) -> list[int]:
    size = math.ceil(len(population) * TOURNAMENT_FRACTION)
    contestants = rng.sample(population, size)
    return max(contestants, key=fitness)


def crossover(
    parent1: list[int], parent2: list[int], rng: random.Random
) -> tuple[list[int], list[int]]:
    child1, child2 = parent1.copy(), parent2.copy()
    if rng.random() < CROSSOVER_PROBABILITY:
        for index in range(CHROMOSOME_LENGTH):
            if rng.random() < 0.5:
                child1[index], child2[index] = child2[index], child1[index]
    return child1, child2


def mutate(child: list[int], rng: random.Random) -> None:
    if rng.random() < MUTATION_PROBABILITY:
        index = rng.randrange(CHROMOSOME_LENGTH)
        child[index] = 1 - child[index]


def print_statistics(generation: int, population: list[list[int]]) -> None:
    scores = [fitness(individual) for individual in population]
    print(
        f"Generation {generation:4d} | Best: {max(scores):5d}"
        f" | Average: {sum(scores) / len(scores):9.2f}"
    )
    top_five = sorted(population, key=fitness, reverse=True)[:5]
    for rank, individual in enumerate(top_five, start=1):
        w, x, y, z = decode(individual)
        print(
            f"  #{rank} | Fitness: {fitness(individual):5d}"
            f" | {format_chromosome(individual)}"
            f" | w = {w}, x = {x}, y = {y}, z = {z}"
        )


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


def main() -> None:
    validate_settings()
    rng = random.Random(RANDOM_SEED)
    population = [
        [rng.randrange(2) for _ in range(CHROMOSOME_LENGTH)]
        for _ in range(POPULATION_SIZE)
    ]
    best = max(population, key=fitness).copy()
    best_generation = 0
    stagnant_generations = 0
    stop_reason = "generation limit reached"

    print("Lab 1: Function maximization with a genetic algorithm")
    print(f"Population: {POPULATION_SIZE} | Generation limit: {MAX_GENERATIONS}")
    print(
        f"Tournament: {TOURNAMENT_FRACTION:.0%}"
        f" ({math.ceil(POPULATION_SIZE * TOURNAMENT_FRACTION)} contestants)"
        f" | Elite: {ELITE_COUNT}"
    )
    print(
        f"Uniform crossover: {CROSSOVER_PROBABILITY:.0%}"
        f" | Single-bit mutation per child: {MUTATION_PROBABILITY:.0%}"
    )
    print(f"Stagnation limit: {STAGNATION_LIMIT} | Seed: {RANDOM_SEED}")
    print_statistics(0, population)

    generation = 0
    for generation in range(1, MAX_GENERATIONS + 1):
        new_population = [best.copy() for _ in range(ELITE_COUNT)]
        while len(new_population) < POPULATION_SIZE:
            parent1 = select_parent(population, rng)
            parent2 = select_parent(population, rng)
            children = crossover(parent1, parent2, rng)
            for child in children:
                if len(new_population) == POPULATION_SIZE:
                    break
                mutate(child, rng)
                new_population.append(child)
        population = new_population

        generation_best = max(population, key=fitness)
        if fitness(generation_best) > fitness(best):
            best = generation_best.copy()
            best_generation = generation
            stagnant_generations = 0
        else:
            stagnant_generations += 1

        if generation % LOG_INTERVAL == 0:
            print_statistics(generation, population)
        if stagnant_generations >= STAGNATION_LIMIT:
            stop_reason = "stagnation limit reached"
            break

    if generation % LOG_INTERVAL != 0:
        print_statistics(generation, population)
    w, x, y, z = decode(best)
    print(f"\nStopped after {generation} generations: {stop_reason}.")
    print(f"Best chromosome: {format_chromosome(best)}")
    print(f"w = {w}, x = {x}, y = {y}, z = {z}")
    print(f"Best fitness: {fitness(best)}")
    print(f"First found at generation: {best_generation}")


if __name__ == "__main__":
    main()
