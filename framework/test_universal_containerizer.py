from calico_framework import TestCase
from tasks import (DockerSleepTask, DockerPingTask)
import calico_framework

if __name__ == "__main__":

    test_name = "Docker"
    sleep_task = DockerSleepTask(netgroups=['netgroup_a'], slave=0)
    ping_task = DockerPingTask(netgroups=['netgroup_a'], slave=0, can_ping_targets=[sleep_task])
    tests = [TestCase([sleep_task], name=test_name)]

    calico_framework.start(tests)
