Mox.defmock(Buildex.Common.Service.MockDatabase, for: Buildex.Common.Services.Database)

Mox.defmock(Buildex.Poller.MockConfig, for: Buildex.Poller.Config)
ExUnit.start()
MecksUnit.mock()
