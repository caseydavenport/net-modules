from calico_framework import TestCase
from tasks import (DockerSleepTask)
import calico_framework

if __name__ == "__main__":

    test_name = "Docker"
    sleep_task = DockerSleepTask(netgroups=['netgroup_a'], slave=0)
    tests = [TestCase([sleep_task], name=test_name)]

    calico_framework.start(tests)
