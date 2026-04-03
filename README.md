# Ghost-Bridge
الالتفاف حول الحجب العميق (DPI) باستخدام أنفاق Cloudflare وسايفون
​Ghost-Bridge هي أداة متطورة تم تطويرها لمستخدمي Termux، تقوم بإنشاء "جسر برمي" (Proxy Bridge) محلي يربط تطبيق Psiphon بشبكة Cloudflare Edge عبر نفق عكسي (Reverse Tunnel). هذه الطريقة تضمن استقرار الاتصال وتجاوز قيود شركات الاتصال التي تحظر بروتوكولات الـ Proxy التقليدية.
​🛠️ كيف يعمل النظام؟ (Architecture)
​يعتمد المشروع على تقنية Chaining (سلسلة الوكلاء):
​العميل (Psiphon): يرسل طلبات CONNECT مشفرة.
​الجسر (Python Proxy): يستقبل الطلبات ويفكك شفرة التوجيه محلياً في بيئة Termux.
​النفق (Cloudflared): ينقل البيانات عبر بروتوكول QUIC المشفر إلى أقرب خادم Cloudflare.
​الخروج: يتم جلب البيانات من الإنترنت العالمي وإعادتها للهاتف بسرعة عالية.
​📦 المتطلبات (Requirements)

نظام أندرويد مع تطبيق Termux.
تثبيت الحزم التالية:

pkg update && pkg install python cloudflared psmisc -y


طريقة التشغيل (Quick Start)
​1. تشغيل النفق العكسي
​في النافذة الأولى لـ Termux، قم بتشغيل النفق:

cloudflared tunnel --url tcp://localhost:8080


2. تشغيل جسر الأشباح (Ghost Proxy)
​في النافذة الثانية، قم بتشغيل سكريبت proxy.py:

python proxy.py


3. إعداد سايفون (Psiphon Settings)
​اذهب إلى الإعدادات > إعدادات الوكيل.
​قم بتفعيل Connect through an HTTP Proxy.
​العنوان: 127.0.0.1 | المنفذ: 8080.
​اضغط ابدأ وانتظر ظهور المفتاح! 🔑




​👤 المطور
​تم التطوير بواسطة: AndroidGhosts Team 💀
"نحن لا نكسر القوانين، نحن فقط نعيد تعريف الوصول."



الاوامر بشكل كامل 
git clone https://github.com/AndroidGhosts/Ghost-Bridge.git



cd Ghost-Bridge

chmod +x ghost.sh

./ghost.sh
<img width="1080" height="2400" alt="1000205201" src="https://github.com/user-attachments/assets/a7a27346-91e3-420a-8815-eb6ae94933b1" />


<img width="1080" height="2400" alt="1000205203" src="https://github.com/user-attachments/assets/f364ffc1-776e-4342-aaca-17d6cd64e61e" />


<img width="1080" height="2400" alt="1000205203" src="https://github.com/user-attachments/assets/a4df764b-8022-443b-b026-4df8d97f93c2" />



