import unittest
import common.timermanager
import tempfile

class TimerManager(unittest.TestCase):
    def test_service_creation(self):
        t=common.timermanager.TimerManager(unit_file_location=tempfile.mkdtemp())
        self.assertFalse(t.timer_and_service_exist())
        t.write_service()
        t.write_timer("*-*-* *:*:00")
        self.assertTrue(t.timer_and_service_exist())

if __name__ == '__main__':
    unittest.main()
