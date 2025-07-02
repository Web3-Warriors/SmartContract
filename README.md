# CrowdFunding Smart Contract with Foundry

Panduan ini akan memandu Anda untuk:

1. Menginstal OpenZeppelin Contracts  
2. Menjalankan jaringan lokal menggunakan Anvil  
3. Mendeploy smart contract menggunakan Foundry pada jaringan anvil

---

## 1. Install OpenZeppelin Contracts

Gunakan Forge untuk menginstal kontrak battle-tested dari OpenZeppelin ke dalam proyek Anda:

```bash
forge install OpenZeppelin/openzeppelin-contracts
```

---

## 2. Jalankan Anvil (Local Blockchain)

Anvil menyediakan blockchain lokal untuk kebutuhan development dan testing. Untuk menjalankannya:

```bash
anvil
```

Anvil akan berjalan di:

```
http://127.0.0.1:8545
```

> ⚠️ Biarkan terminal ini tetap terbuka selama Anda mengembangkan proyek.  
> Saat dijalankan, Anvil akan mencetak daftar alamat dan private key yang dapat digunakan untuk deployment.

---

## 3. Deploy Smart Contract Anda

Setelah Anvil berjalan, deploy smart contract `CrowdFundingContract` Anda menggunakan Forge.

```bash
forge create   --broadcast   --rpc-url http://127.0.0.1:8545   --private-key "YOUR_PRIVATE_KEY"   CrowdfundingContract.sol:CrowdFundingContract
```

> 📝 Ganti `"YOUR_PRIVATE_KEY"` dengan salah satu private key yang dicetak oleh Anvil saat dijalankan.

---

## Requirements

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (`forge`, `anvil`)
- Git
- Solidity ≥ 0.8.x

---

## License

MIT © 2025
