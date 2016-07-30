defmodule Curve448Test do
  use ExUnit.Case
  doctest Curve448

  test "full cycle" do
    {ask, apk} = Curve448.generate_key_pair
    {bsk, bpk} = Curve448.generate_key_pair

    assert byte_size(ask) == 56
    assert byte_size(apk) == 56
    assert byte_size(bsk) == 56
    assert byte_size(bpk) == 56

    refute ask == apk
    refute ask == bsk
    refute ask == bpk
    refute apk == bsk
    refute apk == bpk
    refute bsk == bpk

    assert Curve448.derive_shared_secret(ask,bpk) == Curve448.derive_shared_secret(bsk,apk)

    refute Curve448.derive_shared_secret(bpk,ask) == Curve448.derive_shared_secret(apk,bsk)

  end

  test "improper key sizes" do
    short_key  = "too short a key string and not very random"
    long_key   = "and this key string is too long and still not very random"
    proper_key = "but this key string is just right! -- if not very random"

    refute Curve448.derive_public_key(proper_key) == :error
    assert Curve448.derive_public_key(short_key)  == :error
    assert Curve448.derive_public_key(long_key)   == :error

    refute Curve448.derive_shared_secret(proper_key,proper_key) == :error
    assert Curve448.derive_shared_secret(proper_key,long_key)   == :error
    assert Curve448.derive_shared_secret(proper_key,short_key)  == :error
    assert Curve448.derive_shared_secret(long_key,proper_key)   == :error
    assert Curve448.derive_shared_secret(short_key,proper_key)  == :error
    assert Curve448.derive_shared_secret(short_key,long_key)    == :error
    assert Curve448.derive_shared_secret(long_key,short_key)    == :error
    assert Curve448.derive_shared_secret(long_key,long_key)     == :error
    assert Curve448.derive_shared_secret(short_key,short_key)   == :error
  end

  test "RFC7748 test vectors" do
    # Section 6.2
    a = Base.decode16("9a8f4925d1519f5775cf46b04b5800d4ee9ee8bae8bc5565d498c28dd9c9baf574a9419744897391006382a6f127ab1d9ac2d8c0a598726b")
    a_pub = Base.decode16("9b08f7cc31b7e3e67d22d5aea121074a273bd2b83de09c63faa73d2c22c5d9bbc836647241d953d40c5b12da88120d53177f80e532c41fa0")
    assert a_pub == Curve448.derive_public_key(a)

    b = Base.decode16("1c306a7ac2a0e2e0990b294470cba339e6453772b075811d8fad0d1d6927c120bb5ee8972b0d3e21374c9c921b09d1b0366f10b65173992d")
    b_pub = Base.decode16("3eb7a829b0cd20f5bcfc0b599b6feccf6da4627107bdb0d4f345b43027d8b972fc3e34fb4232a13ca706dcb57aec3dae07bdc1c67bf33609")
    assert b_pub == Curve448.derive_public_key(b)

    k = Base.decode16("07fff4181ac6cc95ec1c16a94a0f74d12da232ce40a77552281d282bb60c0b56fd2464c335543936521c24403085d59a449a5037514a879d")
    assert k == Curve448.derive_shared_secret(a, b_pub)
    assert k == Curve448.derive_shared_secret(b, a_pub)
  end

end
