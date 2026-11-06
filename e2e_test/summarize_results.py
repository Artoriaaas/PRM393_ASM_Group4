"""Summarize pytest JUnit results, never the model's self-reported PASS label."""
import argparse
import csv
import re
from collections import defaultdict
from pathlib import Path
import xml.etree.ElementTree as ET


def summarize(paths):
    cases = defaultdict(list)
    for path in paths:
        for case in ET.parse(path).iter('testcase'):
            name = case.attrib.get('name', '')
            match = re.search(r'TC\d+', name)
            case_id = match.group() if match else ('TC18' if name == 'test_analytics_event_emitted' else name)
            status = 'passed'
            for tag in ('failure', 'error', 'skipped'):
                if case.find(tag) is not None:
                    status = tag
                    break
            cases[case_id].append((status, float(case.attrib.get('time', 0))))
    for case_id, runs in sorted(cases.items()):
        passed = sum(status == 'passed' for status, _ in runs)
        yield [case_id, len(runs), passed,
               sum(status in ('failure', 'error') for status, _ in runs),
               sum(status == 'skipped' for status, _ in runs),
               round(100 * passed / len(runs), 2),
               round(sum(seconds for _, seconds in runs) / len(runs), 2),
               'needs_review' if len(runs) < 3 or passed != len(runs) else 'passed_all_recorded_runs']


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('directory', type=Path, help='One batch containing run-*.xml')
    args = parser.parse_args()
    paths = sorted(args.directory.glob('run-*.xml'))
    if not paths:
        parser.error('No pytest JUnit files; nothing was tested or summarized.')
    with (args.directory / 'summary.csv').open('w', newline='', encoding='utf-8') as stream:
        writer = csv.writer(stream)
        writer.writerow(['case', 'runs', 'passed', 'failed', 'skipped', 'pass_rate_percent', 'average_seconds', 'review'])
        writer.writerows(summarize(paths))
    print(args.directory / 'summary.csv')
