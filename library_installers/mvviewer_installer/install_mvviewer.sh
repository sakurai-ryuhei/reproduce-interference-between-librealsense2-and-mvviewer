#!/usr/bin/env bash
# iRAYPLEカメラや JAKA Lens2dカメラで使用されるライブラリである`MVviewer`をインストールする。

set -ex  # シェルスクリプトの実行モードを「エラーになったら即終了する」＆「コマンドと引数の展開処理を表示する」に指定する。

echo "MVviewerライブラリをインストールします。"

# MVviewerライブラリをインストールする。
# インストーラーは、バージョン更新に対応するために公式URLを使用せずレポジトリ内に保管している。
# ここからダウンロードフォームを送信できる。https://linx.jp/?s=linux+x86&post_type=download&download_cat=irayple_camera&type_name=&product_name=iRAYPLE%E3%82%AB%E3%83%A1%E3%83%A9
# ファイルダウンロードURLの例: https://linx.jp/wordpress/wp-content/uploads/2023/02/Machine_Vision_MVviewer_Client_Ver2_3_2linux_x86.zip
# インストール後は /opt 内に HuarayTech/MVviewerが含まれる。
directory_path_of_this_script=$(dirname $(readlink -f "$0"))
yes yes | sudo $directory_path_of_this_script"/MVviewer_Ver2.3.2_Linux_x86_Build20220401.run" --nox11
