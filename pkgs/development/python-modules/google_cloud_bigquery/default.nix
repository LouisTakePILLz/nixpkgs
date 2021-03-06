{ stdenv, buildPythonPackage, fetchPypi, pytestCheckHook, pythonOlder, freezegun
, google_api_core, google_cloud_core, google_cloud_testutils
, google_resumable_media, grpcio, ipython, mock, pandas, proto-plus, pyarrow }:

buildPythonPackage rec {
  pname = "google-cloud-bigquery";
  version = "2.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "2d53d6fed1c25c9c0ce361dad1c64203c96b2344f7156357a501630d1cb08445";
  };

  disabled = pythonOlder "3.6";

  checkInputs =
    [ freezegun google_cloud_testutils ipython mock pytestCheckHook ];
  propagatedBuildInputs = [
    google_resumable_media
    google_api_core
    google_cloud_core
    pandas
    proto-plus
    pyarrow
  ];

  # prevent google directory from shadowing google imports
  # test_magics requires modifying sys.path
  preCheck = ''
    rm -r google
    rm tests/unit/test_magics.py
  '';

  # call_api_applying_custom_retry_on_timeout requires credentials
  # to_dataframe_timestamp_out_of_pyarrow_bounds has inconsistent results
  disabledTests = [
    "call_api_applying_custom_retry_on_timeout"
    "to_dataframe_timestamp_out_of_pyarrow_bounds"
  ];

  meta = with stdenv.lib; {
    description = "Google BigQuery API client library";
    homepage = "https://pypi.org/project/google-cloud-bigquery";
    license = licenses.asl20;
    maintainers = [ maintainers.costrouc ];
  };
}
