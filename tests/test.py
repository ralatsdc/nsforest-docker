import subprocess
import unittest

class TestNSForestContainer(unittest.TestCase):


    def test_consistency(self):

        # Set up variables
        data_path = "/root/tests/test_data"
        adata_path = f"{data_path}/adata_layer1.h5ad"
        expected_output_path = f"{data_path}/expected_cluster_results.csv"
        output_path = f"{data_path}/cluster_results.csv"
        pp_path = f"{data_path}/pp_adata_layer1.h5ad"
        ns_forest_path = "/root/NSForest/nsforest.py"

        # Run GOEnrich
        subprocess.run(["python",
                        ns_forest_path,
                        adata_path,
                        "--run-nsforest-on-file",
                        "-c", "cluster",
                        "-d", data_path])

        # Compare output with expected output
        with open(output_path) as output:
            with open(expected_output_path) as expected:
                self.assertListEqual(list(output), list(expected))


        # Clean up
        subprocess.run(["rm", output_path])
        subprocess.run(["rm", pp_path])

if __name__ == '__main__':
    unittest.main()