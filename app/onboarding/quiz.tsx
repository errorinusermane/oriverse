import { useState, useEffect } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  ScrollView,
} from 'react-native';
import { router } from 'expo-router';
import { supabase } from '../../src/lib/supabase';
import { useAuthStore } from '../../src/store/authStore';

type QuizQuestion = {
  question: string;
  options: string[];
  correct: number;
};

const QUIZ: Record<string, QuizQuestion[]> = {
  en: [
    {
      question: 'Complete the sentence:\n"She ___ to the gym every morning."',
      options: ['go', 'goes', 'going', 'gone'],
      correct: 1,
    },
    {
      question: 'Which sentence is grammatically correct?',
      options: [
        'There is many people here',
        'There are much people here',
        'There are many people here',
        'There is much people here',
      ],
      correct: 2,
    },
    {
      question: '"If I ___ you, I would apologize."',
      options: ['am', 'was', 'were', 'be'],
      correct: 2,
    },
    {
      question: 'What does "eloquent" mean?',
      options: ['rude', 'well-spoken', 'silent', 'confused'],
      correct: 1,
    },
    {
      question: '"The report ___ submitted before the deadline."',
      options: ['has been', 'have been', 'is been', 'was been'],
      correct: 0,
    },
  ],
  es: [
    {
      question: '"¿Tú ___ estudiante?" (Are you a student?)',
      options: ['eres', 'es', 'soy', 'estás'],
      correct: 0,
    },
    {
      question: '"Ella ___ español muy bien." (She speaks Spanish very well.)',
      options: ['hablar', 'habla', 'hablas', 'hablo'],
      correct: 1,
    },
    {
      question: '"Ayer ___ al mercado." (Yesterday I went to the market.)',
      options: ['voy', 'vaya', 'fui', 'iré'],
      correct: 2,
    },
    {
      question: 'What does "madrugada" mean?',
      options: ['afternoon', 'early morning (before dawn)', 'evening', 'midnight'],
      correct: 1,
    },
    {
      question: '"Los libros ___ en la mesa." (The books are on the table.)',
      options: ['está', 'están', 'es', 'son'],
      correct: 1,
    },
  ],
  de: [
    {
      question: '"Ich ___ aus Korea." (I am from Korea.)',
      options: ['bin', 'bist', 'ist', 'sind'],
      correct: 0,
    },
    {
      question: '"Er ___ ein Buch." (He reads a book.)',
      options: ['lese', 'liest', 'lesen', 'lies'],
      correct: 1,
    },
    {
      question: '"Gestern ___ ich ins Kino gegangen." (Yesterday I went to the cinema.)',
      options: ['habe', 'bin', 'hatte', 'war'],
      correct: 1,
    },
    {
      question: 'What does "Schlange stehen" mean?',
      options: ['to sleep', 'to queue / stand in line', 'to dance', 'to stand tall'],
      correct: 1,
    },
    {
      question: 'What is the correct article for "Haus" (house)?',
      options: ['der Haus', 'die Haus', 'das Haus', 'den Haus'],
      correct: 2,
    },
  ],
  fr: [
    {
      question: '"Je ___ étudiant." (I am a student.)',
      options: ['suis', 'es', 'est', 'sommes'],
      correct: 0,
    },
    {
      question: '"Elle ___ au café." (She goes to the café.)',
      options: ['vais', 'vas', 'va', 'vont'],
      correct: 2,
    },
    {
      question: '"Hier, j\'___ mangé au restaurant." (Yesterday I ate at the restaurant.)',
      options: ['ai', 'as', 'a', 'ont'],
      correct: 0,
    },
    {
      question: 'What does "se débrouiller" mean?',
      options: ['to struggle hopelessly', 'to manage / get by', 'to fail', 'to brush hair'],
      correct: 1,
    },
    {
      question: '"Les enfants ___ contents." (The children are happy.)',
      options: ['est', 'sont', 'suis', 'êtes'],
      correct: 1,
    },
  ],
  zh: [
    {
      question: '"你好" means:',
      options: ['Thank you', 'Goodbye', 'Hello', 'Sorry'],
      correct: 2,
    },
    {
      question: 'Which means "I like to eat"?',
      options: ['我不喜欢吃', '你喜欢吃', '我喜欢吃', '他喜欢吃'],
      correct: 2,
    },
    {
      question: '"昨天我___北京。" (Yesterday I went to Beijing.)',
      options: ['去', '去了', '要去', '去过'],
      correct: 1,
    },
    {
      question: 'What does "一言为定" (yī yán wéi dìng) mean?',
      options: ["Say one word", "It's a deal / Agreed", "Speak louder", "One language"],
      correct: 1,
    },
    {
      question: '"他的汉语说得___。" (His Chinese is spoken well.) Best option:',
      options: ['好', '很好', '非常', '最'],
      correct: 1,
    },
  ],
  ja: [
    {
      question: '"私は学生___。" (I am a student.)',
      options: ['だ', 'です', 'ます', 'でした'],
      correct: 1,
    },
    {
      question: '"毎朝、コーヒーを___。" (I drink coffee every morning.)',
      options: ['飲む', '飲みます', '飲んで', '飲んだ'],
      correct: 1,
    },
    {
      question: '"昨日、映画を___ました。" (Yesterday I watched a movie.)',
      options: ['見', '見て', '見る', '見た'],
      correct: 0,
    },
    {
      question: '"おつかれさまです" is used to:',
      options: [
        'Greet in the morning',
        "Acknowledge someone's hard work",
        'Say farewell forever',
        'Order food politely',
      ],
      correct: 1,
    },
    {
      question: '"学校___行きます。" Choose the correct particle. (I go to school.)',
      options: ['を', 'で', 'に', 'は'],
      correct: 2,
    },
  ],
  ko: [
    {
      question: '"저는 학생___." Choose the polite ending.',
      options: ['이야', '입니다', '야', '이다'],
      correct: 1,
    },
    {
      question: '"어제 친구를 ___." (Yesterday I met a friend.)',
      options: ['만나', '만납니다', '만났어요', '만나요'],
      correct: 2,
    },
    {
      question: '"그 영화는 정말 ___." Politely: "That movie is really interesting."',
      options: ['재미있어요', '재미있다', '재미있고', '재미있으면'],
      correct: 0,
    },
    {
      question: 'What does "눈치" describe?',
      options: [
        'The ability to read social situations',
        'Eye contact skills',
        'Physical coordination',
        'Punctuality',
      ],
      correct: 0,
    },
    {
      question: '"비가 ___ 우산을 가져가세요." (Since it\'s raining, take an umbrella.)',
      options: ['오고', '오니까', '오면', '와서'],
      correct: 1,
    },
  ],
};

function getOptionClass(idx: number, correct: number, selected: number | null): string {
  const base = 'p-4 rounded-xl border-2 mb-3';
  if (selected === null) return `${base} border-gray-200 bg-white`;
  if (idx === correct) return `${base} border-green-500 bg-green-50`;
  if (idx === selected) return `${base} border-red-400 bg-red-50`;
  return `${base} border-gray-100 bg-gray-50`;
}

function getOptionTextClass(idx: number, correct: number, selected: number | null): string {
  if (selected === null) return 'text-base font-medium text-gray-800';
  if (idx === correct) return 'text-base font-medium text-green-700';
  if (idx === selected) return 'text-base font-medium text-red-600';
  return 'text-base font-medium text-gray-400';
}

export default function OnboardingQuiz() {
  const { user } = useAuthStore();
  const [questions, setQuestions] = useState<QuizQuestion[]>([]);
  const [languageId, setLanguageId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [currentQ, setCurrentQ] = useState(0);
  const [answers, setAnswers] = useState<(number | null)[]>(Array(5).fill(null));
  const [selected, setSelected] = useState<number | null>(null);
  const [showResult, setShowResult] = useState(false);
  const [score, setScore] = useState(0);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (!user) return;
    (async () => {
      const { data: userData } = await supabase
        .from('users')
        .select('learning_language_id')
        .eq('id', user.id)
        .single();

      const langId = userData?.learning_language_id ?? null;
      setLanguageId(langId);

      if (langId) {
        const { data: langData } = await supabase
          .from('languages')
          .select('code')
          .eq('id', langId)
          .single();
        const code = langData?.code ?? 'en';
        setQuestions(QUIZ[code] ?? QUIZ.en);
      } else {
        setQuestions(QUIZ.en);
      }

      setLoading(false);
    })();
  }, [user]);

  const handleSelect = (optionIdx: number) => {
    if (selected !== null) return;
    setSelected(optionIdx);
  };

  const handleNext = () => {
    const newAnswers = [...answers];
    newAnswers[currentQ] = selected;
    setAnswers(newAnswers);

    if (currentQ < questions.length - 1) {
      setCurrentQ(currentQ + 1);
      setSelected(null);
    } else {
      const finalScore = newAnswers.reduce<number>((acc, answer, idx) => {
        return acc + (answer === questions[idx].correct ? 1 : 0);
      }, 0);
      setScore(finalScore);
      setShowResult(true);
    }
  };

  const handleFinish = async () => {
    if (!user) return;
    setSaving(true);
    const level = score >= 3 ? 'intermediate' : 'beginner';

    if (languageId) {
      await supabase.from('user_level_quiz').insert({
        user_id: user.id,
        language_id: languageId,
        result: level,
      });
    }

    const { error } = await supabase
      .from('users')
      .update({ onboarding_step: 3 })
      .eq('id', user.id);

    setSaving(false);
    if (error) { Alert.alert('오류', error.message); return; }
    router.replace('/(tabs)/learn');
  };

  if (loading) {
    return (
      <View className="flex-1 items-center justify-center bg-white">
        <ActivityIndicator size="large" color="#3B82F6" />
      </View>
    );
  }

  // Result screen
  if (showResult) {
    const isIntermediate = score >= 3;
    return (
      <View className="flex-1 bg-white items-center justify-center px-8">
        <Text className="text-6xl mb-6">{isIntermediate ? '🎯' : '📚'}</Text>
        <Text className="text-2xl font-bold text-gray-900 text-center mb-2">
          {isIntermediate ? '중급 레벨이에요!' : '초급 레벨이에요!'}
        </Text>
        <Text className="text-gray-500 text-center mb-2">
          5문제 중 {score}개 정답
        </Text>
        <Text className="text-sm text-gray-400 text-center mb-10">
          {isIntermediate
            ? '이미 기초 실력이 있네요! 더 빠르게 성장할 수 있어요.'
            : '처음부터 차근차근 시작해봐요. 곧 실력이 늘 거예요!'}
        </Text>
        <TouchableOpacity
          onPress={handleFinish}
          disabled={saving}
          className="bg-blue-500 py-4 rounded-2xl w-full items-center"
        >
          {saving ? (
            <ActivityIndicator color="white" />
          ) : (
            <Text className="text-white text-base font-bold">학습 시작하기</Text>
          )}
        </TouchableOpacity>
      </View>
    );
  }

  const question = questions[currentQ];

  return (
    <ScrollView
      className="flex-1 bg-white"
      contentContainerStyle={{ flexGrow: 1 }}
      keyboardShouldPersistTaps="handled"
    >
      {/* Header / progress */}
      <View className="pt-14 px-6 pb-4">
        <View className="flex-row gap-2 mb-6">
          <View className="flex-1 h-1 rounded-full bg-blue-500" />
          <View className="flex-1 h-1 rounded-full bg-blue-500" />
          <View className="flex-1 h-1 rounded-full bg-blue-500" />
        </View>
        <View className="flex-row justify-between items-center mb-3">
          <Text className="text-sm font-medium text-gray-400">3 / 3단계 · 레벨 퀴즈</Text>
          <Text className="text-sm text-gray-400">{currentQ + 1} / {questions.length}</Text>
        </View>
        {/* Per-question progress bar */}
        <View className="w-full h-1.5 bg-gray-200 rounded-full">
          <View
            className="h-1.5 bg-blue-500 rounded-full"
            style={{ width: `${((currentQ + 1) / questions.length) * 100}%` }}
          />
        </View>
      </View>

      {/* Question */}
      <View className="flex-1 px-6 pt-4">
        <Text className="text-xl font-bold text-gray-900 mb-8 leading-8">
          {question.question}
        </Text>

        {/* Options */}
        {question.options.map((option, idx) => (
          <TouchableOpacity
            key={idx}
            onPress={() => handleSelect(idx)}
            disabled={selected !== null}
            className={getOptionClass(idx, question.correct, selected)}
          >
            <Text className={getOptionTextClass(idx, question.correct, selected)}>
              {String.fromCharCode(65 + idx)}. {option}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* CTA */}
      <View className="px-6 pb-10 pt-4">
        <TouchableOpacity
          onPress={handleNext}
          disabled={selected === null}
          className={
            selected !== null
              ? 'py-4 rounded-2xl items-center bg-blue-500'
              : 'py-4 rounded-2xl items-center bg-gray-200'
          }
        >
          <Text
            className={
              selected !== null
                ? 'text-base font-bold text-white'
                : 'text-base font-bold text-gray-400'
            }
          >
            {currentQ === questions.length - 1 ? '결과 보기' : '다음'}
          </Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}
