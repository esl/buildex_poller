defmodule Buildex.Poller.Repository.GithubFake do
  @behaviour Buildex.Poller.Repository.Adapter

  alias Buildex.Common.Repos.Repo
  alias Buildex.Common.Tags.Tag

  @new_tags [
    %Tag{
      commit: %{
        sha: "2b338092b6da5cd5101072dfdd627cfbb49e4736",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/2b338092b6da5cd5101072dfdd627cfbb49e4736"
      },
      name: "v1.7.2",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS43LjI=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.2",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.2"
    },
    %Tag{
      commit: %{
        sha: "8aab53b941ee955f005e7b4e08c333f0b94c48b7",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/8aab53b941ee955f005e7b4e08c333f0b94c48b7"
      },
      name: "v1.7.1",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS43LjE=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.1",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.1"
    },
    %Tag{
      commit: %{
        sha: "06e5ec2d4c628e57440b0a393e4efa98e7226173",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/06e5ec2d4c628e57440b0a393e4efa98e7226173"
      },
      name: "v1.7.0",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS43LjA=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.0",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.0"
    },
    %Tag{
      commit: %{
        sha: "b6d77696743a34ade6a222cbe2811440ae4e0018",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/b6d77696743a34ade6a222cbe2811440ae4e0018"
      },
      name: "v1.7.0-rc.1",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS43LjAtcmMuMQ==",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.0-rc.1",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.0-rc.1"
    },
    %Tag{
      commit: %{
        sha: "1164784b8ef25967471c068600301db850de58b3",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/1164784b8ef25967471c068600301db850de58b3"
      },
      name: "v1.7.0-rc.0",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS43LjAtcmMuMA==",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.7.0-rc.0",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.7.0-rc.0"
    },
    %Tag{
      commit: %{
        sha: "1ec9d1d7bdd01665deb3607ba6beb8bcd524b85d",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/1ec9d1d7bdd01665deb3607ba6beb8bcd524b85d"
      },
      name: "v1.6.6",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS42LjY=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.6.6",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.6.6"
    },
    %Tag{
      commit: %{
        sha: "a9f1be07ca1a939739bd013f100686c8cf81432a",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/a9f1be07ca1a939739bd013f100686c8cf81432a"
      },
      name: "v1.6.5",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS42LjU=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.6.5",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.6.5"
    },
    %Tag{
      commit: %{
        sha: "c107a2fe2623d11d132cdfeefbb7370abd44f85c",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/c107a2fe2623d11d132cdfeefbb7370abd44f85c"
      },
      name: "v1.6.4",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS42LjQ=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.6.4",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.6.4"
    },
    %Tag{
      commit: %{
        sha: "45c7f828ef7cb29647d4ac999761ed4e2ff0dc08",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/45c7f828ef7cb29647d4ac999761ed4e2ff0dc08"
      },
      name: "v1.6.3",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS42LjM=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.6.3",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.6.3"
    },
    %Tag{
      commit: %{
        sha: "c2a9c93f023c0c00e5f387a1476f4cca01752bb8",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/c2a9c93f023c0c00e5f387a1476f4cca01752bb8"
      },
      name: "v1.6.2",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS42LjI=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.6.2",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.6.2"
    },
    %Tag{
      commit: %{
        sha: "2b588dfb3ebb2f3221bec3509cb1dbb8e08ef1af",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/2b588dfb3ebb2f3221bec3509cb1dbb8e08ef1af"
      },
      name: "v1.6.1",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS42LjE=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.6.1",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.6.1"
    },
    %Tag{
      commit: %{
        sha: "63b8d0ba34f38baa6f3a11020215b2f66213d27e",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/63b8d0ba34f38baa6f3a11020215b2f66213d27e"
      },
      name: "v1.6.0",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS42LjA=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.6.0",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.6.0"
    },
    %Tag{
      commit: %{
        sha: "67e575eca7b97d4fe063626671d1fd1da0ba7fed",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/67e575eca7b97d4fe063626671d1fd1da0ba7fed"
      },
      name: "v1.6.0-rc.1",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS42LjAtcmMuMQ==",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.6.0-rc.1",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.6.0-rc.1"
    },
    %Tag{
      commit: %{
        sha: "182c730bdb431fd1ff6789057e4903c33e377f43",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/182c730bdb431fd1ff6789057e4903c33e377f43"
      },
      name: "v1.6.0-rc.0",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS42LjAtcmMuMA==",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.6.0-rc.0",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.6.0-rc.0"
    },
    %Tag{
      commit: %{
        sha: "7340ca2d925297e98dd71528a09bf0fb8634b47f",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/7340ca2d925297e98dd71528a09bf0fb8634b47f"
      },
      name: "v1.5.3",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS41LjM=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.5.3",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.5.3"
    },
    %Tag{
      commit: %{
        sha: "05418eaa4bf4fa8473900741252d93d76ed3307b",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/05418eaa4bf4fa8473900741252d93d76ed3307b"
      },
      name: "v1.5.2",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS41LjI=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.5.2",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.5.2"
    },
    %Tag{
      commit: %{
        sha: "1406d853e0e6515007696f871d0a9e2c023da6da",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/1406d853e0e6515007696f871d0a9e2c023da6da"
      },
      name: "v1.5.1",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS41LjE=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.5.1",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.5.1"
    },
    %Tag{
      commit: %{
        sha: "117b2bf614d4b74281ff6dfe0e0e95caf50ff100",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/117b2bf614d4b74281ff6dfe0e0e95caf50ff100"
      },
      name: "v1.5.0",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS41LjA=",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.5.0",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.5.0"
    },
    %Tag{
      commit: %{
        sha: "e5208421b32f197379b26c55bfde22651bea5e1c",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/e5208421b32f197379b26c55bfde22651bea5e1c"
      },
      name: "v1.5.0-rc.2",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS41LjAtcmMuMg==",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.5.0-rc.2",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.5.0-rc.2"
    },
    %Tag{
      commit: %{
        sha: "704fb9599b522bb530efdc5bb527d005e0c8ed68",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/704fb9599b522bb530efdc5bb527d005e0c8ed68"
      },
      name: "v1.5.0-rc.1",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS41LjAtcmMuMQ==",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.5.0-rc.1",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.5.0-rc.1"
    },
    %Tag{
      commit: %{
        sha: "fa0de77862f10496f8285079c7cdc367ead7c8c8",
        url:
          "https://api.github.com/repos/elixir-lang/elixir/commits/fa0de77862f10496f8285079c7cdc367ead7c8c8"
      },
      name: "v1.5.0-rc.0",
      node_id: "MDM6UmVmMTIzNDcxNDp2MS41LjAtcmMuMA==",
      tarball_url: "https://api.github.com/repos/elixir-lang/elixir/tarball/v1.5.0-rc.0",
      zipball_url: "https://api.github.com/repos/elixir-lang/elixir/zipball/v1.5.0-rc.0"
    }
  ]
  @spec get_tags(Repo.t()) ::
          {:ok, list(Tag.t())} | {:error, :rate_limit, pos_integer()} | {:error, any()}
  def get_tags(%{owner: "rate-limit"}) do
    {:error, :rate_limit, 50}
  end

  def get_tags(%{owner: "404"}) do
    {:error, :not_found}
  end

  def get_tags(%{owner: "2-new-tags"}) do
    {:ok, Enum.take(@new_tags, 2)}
  end

  def get_tags(%{owner: "new-tag"}) do
    {:ok, Enum.take(@new_tags, 1)}
  end

  def get_tags(%{owner: "no-tags"}) do
    {:ok, []}
  end

  def get_tags(_) do
    {:ok, @new_tags}
  end
end
