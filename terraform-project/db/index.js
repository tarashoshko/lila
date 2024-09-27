const { MongoClient } = require('mongodb');
const https = require('https');

// Функція для завантаження indexes.js з GitHub
const downloadIndexesScript = () => {
  return new Promise((resolve, reject) => {
    https.get('https://raw.githubusercontent.com/tarashoshko/lila/main/bin/mongodb/indexes.js', (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        resolve(data);
      });
    }).on('error', (err) => {
      reject(err);
    });
  });
};

exports.handler = async (event) => {
  const uri = `mongodb://${process.env.DB_USERNAME}:${process.env.DB_PASSWORD}@${process.env.DB_ENDPOINT}:27017/admin`;
  const client = new MongoClient(uri);

  try {
    // Підключаємось до MongoDB
    await client.connect();

    // Створюємо базу даних, просто підключившись до неї
    const db = client.db('lila'); // Замість 'lila' вкажіть ваше ім'я бази даних

    // Завантажуємо скрипт indexes.js з GitHub
    const scriptContent = await downloadIndexesScript();
    
    // Виконуємо скрипт індексів у контексті MongoDB
    eval(scriptContent);

    console.log('Індексація виконана успішно');
  } catch (error) {
    console.error('Помилка при ініціалізації індексів:', error);
    throw error;
  } finally {

    await client.close();
  }
};

