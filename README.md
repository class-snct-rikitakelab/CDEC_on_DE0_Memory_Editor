#プロジェクトの使い方  
DE0-CV向けです。  

Quartus_Project内の.pofファイルを書き込むことで不揮発化できます。  
Nios�U用プログラムのrom化もしているため、  
.sofファイルか.posファイルを書き込むだけで動作します。  


GPIO_1_D31とGPIO_1_D33をそれぞれrxd、txdとしています。  
パソコンとシリアル通信用ケーブルなどで接続してください。  


Packaged_AppはChromeで読み込んで動かします。  
プルダウンメニューから接続したCOMポートを選択し、  
openボタンでコネクションを確立します。  
コネクション確立後、writeボタンでテーブルに入力されているプログラムを  
CDECへ書き込みます。  
プログラムは16進2桁で入力してください、それ以外の場合セルが黄色くなります。  
readボタンでCDECに書き込まれたプログラムを読み出してテーブルへ入力します。  
コネクションを切る場合はcloseボタンです。  

