# GLSL

このリポジトリは Tsuyoshi.A@壊れたプログラマーもどきが、  
GLSLの勉強で書いたシェーダーソースコードです。  
色々なWebサイトや書籍を参考、独自で作ったものなどごちゃまぜです。

Visual Studio Code(以下 VSCode)の拡張である、**glsl-canvas** で実行できる形式となっています。  
通常のGLSLで使用する場合は、整形作業といったひと手間が必要です。

## フォルダ構成

- .vscode
  - VSCode Projectsのローカル設定
- GLSL
  - glsl-canvas形式のGLSLソースコード

## ファイルの構成
- color.glsl
  - カラーグラデーションの回転
- crossfade.glsl
  - シェーダーでのクロスフェード
- diffuse_shading.glsl
  - ディフューズシェーディング
- discacrd.glsl
  - discardを使ってワイヤーフレーム的な表示を試した
- division_barrel.glsl
  - テクスチャ分割とBarrel Distortion表現
- flat_shading.vs
  - フラットシェーディング (拡張子間違えてる…)
- fog.glsl
  - フラグメントシェーダでのフォグ（fogMaxでかかり具合変更）
- fog2.glsl
  - 頂点シェーダでのフォグ（fogMaxでかかり具合変更）
- light_anim.fs
  - ライトのアニメーション1
- light_anim2.fs
  - ライトのアニメーション2
- light_anim3.fs
  - ライトのアニメーション3
- light_anim4.fs
  - ライトのアニメーション4
- monochrome.glsl
  - モノクロ表示
- mosaic.glsl
  - モザイク表示
- multi_right.glsl
  - 複数のライトを使った表示
- nega.glsl
  - ネガポジ表示
- noise.glsl
  - ノイズ表示
- phong_shading.glsl
  - フォンシェーディング
- quaternion.glsl
  - クォータニオン関数
- quaternion_test.glsl
  - クォータニオン関数のテスト
- raymarch.fs
  - レイマーチの勉強（基本編）
- raymarch2.fs
  - レイマーチの勉強（応用編）
- sample.glsl
  - glsl-vanvas のサンプルコード
- sepia.glsl
  - セピア調表現
- shape.glsl
  - 格子状のテスト
- spotlight.glsl
  - スポットライト
- template.glsl
  - 新規作成する場合のテンプレートコード
- test.fs
  - glsl-canvas の使い方を学ぶのに使用
- tile.glsl
  - タイルアニメーション
- toon_shading.glsl
  - 簡易トゥーンシェーダー
- wave.glsl
  - 波の表現（旗のなびき）
- wave2.glsl
  - 波の表現2（より波を強く）

## 参考
- quaternion
  - https://qiita.com/aa_debdeb/items/c34a3088b2d8d3731813
- raymarch
  - https://wgld.org/d/glsl/

## テクスチャ
- amiya.png
  - https://arknights.wikiru.jp/index.php?%A5%A2%A1%BC%A5%DF%A5%E4
- W_01.png
  - https://arknights.wikiru.jp/index.php?W%28%A5%D7%A5%EC%A5%A4%A5%A2%A5%D6%A5%EB%29

## 使い方
VSCodeでファイルを開いて、glslCanvas を表示してください。

## 今後
勉強で作成したシェーダーファイルがある程度たまったら追加していきます。  
マルチテクスチャやバッファが使えるので、バンプマップや影の勉強したい。  
最終目標はレイマーチとしておく。

## ライセンス
他のリポジトリの流れでMIT License…に設定していますが、ご自由にお使いくださいライセンスです。
