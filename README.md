# XOR暗号画像

`share1.png` と `share2.png` は、どちらも「きれい画像」と読めるランダム模様の画像。
2枚をピクセル単位でXORすると、共通部分が消え、`merged.png` にシルエットだけが現れる。

## 生成

```sh
./make-demo.sh
```

## 手動でマージ

```sh
magick share1.png share2.png \
  -colorspace sRGB -alpha off -evaluate-sequence Xor -depth 8 \
  out.png
```

`out.png` は `secret.png` と一致。

## 原理

`share2 = share1 XOR secret` としているため、再度XORすると、

```text
share1 XOR share2
= share1 XOR share1 XOR secret
= secret
```

となる。
