# File Transfer

# ECC : RTL design of elliptic curve cryptography
  --> SM2 Encrypt
  --> SM2 Decrypt
  --> SM2 Key Share
      --> Elliptic Curve Scalar Multiplication
          --> Point Add
          --> Point Double
              --> Modadd
              --> Modsub
              --> Modmul
              --> Moddiv
      --> SHA256 Hash Algorithm
  --> Spi Interface

# ibm : IBM Opencai -- RTL design of High Performance Mixed Cryptography System
  --> AES 5 Stage Pipeline Cryptography
  --> Elliptic Curve Scalar Multiplication
          --> Point Add
          --> Point Double
              --> Modadd
              --> Modsub
              --> Modmul
              --> Moddiv
  --> SM3 Hash Algorithm
  --> SM4 Block Cipher Algorithm

# Montgomery Ladder : Montgomery Ladder implementation of SM2
  --> SM2 Digital Signature
  --> SM2 Digital Signature Verify
  --> SM2 Key Share
  --> SM2 Public/Privacy Key Generate
  --> SM2 Encrypt
  --> SM2 Decrypt
      --> 2 Stage Pipeline Ozturk Multiplier
      --> Polynomial Coefficient Adder
      --> Polynomial Coefficient Substractor
      --> Improved Binary Extend Euclidean Algorithm for Modular Division
  --> Spi Interface
  

