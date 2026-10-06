import importlib.machinery
import importlib.util
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
loader = importlib.machinery.SourceFileLoader('service_power', str(Path(__file__).resolve().parents[1] / 'contents/code/komapowercontrol'))
spec = importlib.util.spec_from_loader(loader.name, loader)
power = importlib.util.module_from_spec(spec)
loader.exec_module(power)

class ServiceTests(unittest.TestCase):
    def test_store_install_creates_service_once_without_enabling_autostart(self):
        with tempfile.TemporaryDirectory() as folder, patch.dict(os.environ, {'XDG_CONFIG_HOME': folder}), patch.object(power.subprocess, 'run') as run:
            power.ensure_service()
            unit = Path(folder) / 'systemd/user' / power.UNIT
            self.assertIn('BusName=' + power.NAME, unit.read_text())
            self.assertIn(' hold\n', unit.read_text())
            self.assertNotIn('[Install]', unit.read_text())
            power.ensure_service()
            run.assert_called_once()

if __name__ == '__main__':
    unittest.main()
