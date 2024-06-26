{ lib
, buildPythonPackage
, fetchFromGitHub
, google-ai-generativelanguage
, google-api-core
, google-auth
, protobuf
, pythonOlder
, pythonRelaxDepsHook
, pydantic
, tqdm
, typing-extensions
}:

buildPythonPackage rec {
  pname = "google-generativeai";
  version = "0.4.0";
  format = "setuptools";

  disabled = pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "google";
    repo = "generative-ai-python";
    rev = "refs/tags/v${version}";
    hash = "sha256-SrWAjvSqfHGMOe1hM0R4CBTOn+NsQtzR6b0hVn75LqY=";
  };

  pythonRelaxDeps = [
    "google-ai-generativelanguage"
  ];

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  propagatedBuildInputs = [
    google-ai-generativelanguage
    google-auth
    google-api-core
    protobuf
    pydantic
    tqdm
    typing-extensions
  ];

  # Issue with the google.ai module. Check with the next release
  doCheck = false;

  pythonImportsCheck = [
    "google.generativeai"
  ];

  meta = with lib; {
    description = "Python client library for Google's large language model PaLM API";
    homepage = "https://github.com/google/generative-ai-python";
    changelog = "https://github.com/google/generative-ai-python/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
