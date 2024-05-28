{ lib, buildGoModule, fetchFromGitHub, testers, flyctl, installShellFiles, gitUpdater }:

buildGoModule rec {
  pname = "flyctl";
  version = "0.2.55";

  src = fetchFromGitHub {
    owner = "superfly";
    repo = "flyctl";
    rev = "v${version}";
    hash = "sha256-yCRaF600UrDmazsgTRp/grWtkULeSQedE5m69K6h/4Q=";
  };

  vendorHash = "sha256-1hlWyr41t8J4naN5QbEtfCv3npe/kvMH5NKKaxYvLYk=";

  subPackages = [ "." ];

  ldflags = [
    "-s" "-w"
    "-X github.com/superfly/flyctl/internal/buildinfo.buildDate=1970-01-01T00:00:00Z"
    "-X github.com/superfly/flyctl/internal/buildinfo.buildVersion=${version}"
  ];
  tags = ["production"];

  nativeBuildInputs = [ installShellFiles ];

  patches = [ ./disable-auto-update.patch ];

  preBuild = ''
    go generate ./...
  '';

  preCheck = ''
    HOME=$(mktemp -d)
  '';

  checkFlags = [
    # these tests require network
    "-skip=TestToTestMachineConfig"
  ];

  # We override checkPhase to be able to test ./... while using subPackages
  checkPhase = ''
    runHook preCheck
    # We do not set trimpath for tests, in case they reference test assets
    export GOFLAGS=''${GOFLAGS//-trimpath/}

    buildGoDir test ./...

    runHook postCheck
  '';

  postInstall = ''
    installShellCompletion --cmd flyctl \
      --bash <($out/bin/flyctl completion bash) \
      --fish <($out/bin/flyctl completion fish) \
      --zsh <($out/bin/flyctl completion zsh)
    ln -s $out/bin/flyctl $out/bin/fly
  '';

  # Upstream tags every PR merged with release tags like
  # v2024.5.20-pr3545.4. We ignore all revisions containing a '-'
  # to skip these releases.
  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    ignoredVersions = "-";
  };

  passthru.tests.version = testers.testVersion {
    package = flyctl;
    command = "HOME=$(mktemp -d) flyctl version";
    version = "v${flyctl.version}";
  };

  meta = {
    description = "Command line tools for fly.io services";
    downloadPage = "https://github.com/superfly/flyctl";
    homepage = "https://fly.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ adtya jsierles techknowlogick RaghavSood ];
    mainProgram = "flyctl";
  };
}
