import argparse
import subprocess
import sys

# Import PlatformUtils from the model zoo code
sys.path.insert(0, "benchmarks/common")
import platform_util


class LaunchMultiInstanceBenchmark(object):
    def __init__(self, args):
        self.args = args
        self.platform = platform_util.PlatformUtil(self.args)

        cpu_info_list, test_cores_list = self.cpu_info(self.args.cores_per_instance)
        print(cpu_info_list)
        print(test_cores_list)

    def list_of_groups(self, init_list, children_list_len):
        children_list_len = int(children_list_len)
        list_of_groups = zip(*(iter(init_list),) * children_list_len)
        end_list = [list(i) for i in list_of_groups]
        count = len(init_list) % children_list_len
        end_list.append(init_list[-count:]) if count != 0 else end_list
        return end_list

    def cpu_info(self, cores_per_instance):

        num_physical_cores = self.platform.num_cpu_sockets * self.platform.num_cores_per_socket
        cores_per_node = int(num_physical_cores / self.platform.num_numa_nodes)
        cpu_array_shell = \
            "numactl -H |grep 'node [0-9]* cpus:' |" \
            "sed 's/.*node [0-9]* cpus: *//' | head -{0} |cut -f1-{1} -d' '".format(
            self.platform.num_numa_nodes, int(cores_per_node))

        cpu_array = subprocess.Popen(cpu_array_shell, shell=True,
                                     stdout=subprocess.PIPE)
        cpu_array_output = cpu_array.stdout.readlines()
        cpu_cores_string = ''
        for one_core in cpu_array_output:
            new_one_core = str(one_core).lstrip("b'").replace("\\n'", " ")
            cpu_cores_string += new_one_core
        cpu_cores_list = cpu_cores_string.split(" ")
        new_cpu_cores_list = [x for x in cpu_cores_list if x != '']
        test_cores_list = self.list_of_groups(new_cpu_cores_list, cores_per_instance)
        cpu_info_list = [self.platform.num_cpu_sockets,
                         self.platform.num_cores_per_socket,
                         self.platform.num_numa_nodes,
                         num_physical_cores,
                         cores_per_node,
                         cores_per_instance,
                         self.platform.num_numa_nodes]
        return cpu_info_list, test_cores_list


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="run LZ models jenkins")
    parser.add_argument("--cores_per_instance", "-cpi",
                        help="select realtime every instance used cores number",
                        default=4)

    args = parser.parse_args()
    LaunchMultiInstanceBenchmark(args)
