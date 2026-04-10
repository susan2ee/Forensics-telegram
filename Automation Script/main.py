# chromedriver.exe --port=9515 --allowed-ips=127.0.0.1,10.0.2.2
import argparse
import yaml

from config import ENABLE_VM_DUMP
from automation_script_A import run_scenarios as run_a
from automation_script_K import run_scenarios as run_k

def load_scenario(path: str):
    with open(path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--browser",
        choices=["chrome", "firefox"],
        default="chrome",
        help="Browser to use",
    )

    parser.add_argument(
        "--tg-version",
        choices=["a", "k"],
        default="a",
        dest="tg_version",
        help="Telegram Web version to use",
    )

    parser.add_argument(
        "--mode",
        choices=["normal", "private"],
        default="normal",
        help="Browser tab/window mode",
    )

    parser.add_argument(
        "--scenario-file",
        default="scenario.yaml",
        help="Path to scenario YAML file",
    )

    parser.set_defaults(enable_dump=ENABLE_VM_DUMP)
    return parser.parse_args()


def main():
    args = parse_args()

    runner_map = {
        "a": run_a,
        "k": run_k,
    }

    selected_runner = runner_map[args.tg_version]
    scenario = load_scenario(args.scenario_file)

    selected_runner(
        browser=args.browser,
        browser_mode=args.mode,
        enable_dump=args.enable_dump,
        scenario=scenario,
    )


if __name__ == "__main__":
    main()
