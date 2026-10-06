import importlib.machinery
import importlib.util
from pathlib import Path
import unittest

loader = importlib.machinery.SourceFileLoader('power', str(Path(__file__).resolve().parents[1] / 'contents/code/komapowercontrol'))
spec = importlib.util.spec_from_loader(loader.name, loader)
power = importlib.util.module_from_spec(spec)
loader.exec_module(power)

class BatteryTests(unittest.TestCase):
    def test_no_battery(self):
        self.assertFalse(power.battery_info({'Type': 0, 'IsPresent': False})['present'])
    def test_charging_uses_time_to_full(self):
        value = power.battery_info({'Type': 2, 'IsPresent': True, 'State': 1, 'Percentage': 52,
                                    'TimeToFull': 3600, 'TimeToEmpty': 7200, 'EnergyFull': 33})
        self.assertTrue(value['present'])
        self.assertEqual(value['seconds'], 3600)
        self.assertEqual(value['status'], 'Charging')
    def test_discharging_uses_time_to_empty(self):
        self.assertEqual(power.battery_info({'State': 2, 'TimeToFull': 60, 'TimeToEmpty': 120})['seconds'], 120)
    def test_unknown_cycles_not_zero(self):
        self.assertEqual(power.battery_info({})['cycles'], -1)
    def test_clamp_percentage(self):
        self.assertEqual(power.battery_info({'Percentage': 105})['percent'], 100)
