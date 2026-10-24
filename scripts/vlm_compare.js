import ZAI from 'z-ai-web-dev-sdk';
import fs from 'fs';

async function main() {
  const f0 = fs.readFileSync('/home/omar/proyectos/comi_colima/nodos/video/frame0_16oct.png');
  const f600 = fs.readFileSync('/home/omar/proyectos/comi_colima/nodos/video/frame600_16oct.png');
  const zai = await ZAI.create();
  const resp = await zai.chat.completions.createVision({
    messages: [{
      role: 'user',
      content: [
        { type: 'text', text: 'These two images are frames 0 and 600 (10 seconds apart) from a robot POV camera. The robot was supposed to move toward a white pillar. Did the pillar get visibly LARGER (closer) in the second image vs the first? Answer with one word: MOVED, STATIC, or MOVED_BACK. Then in one sentence describe what changed.' },
        { type: 'image_url', image_url: { url: 'data:image/png;base64,' + f0.toString('base64') } },
        { type: 'image_url', image_url: { url: 'data:image/png;base64,' + f600.toString('base64') } }
      ]
    }],
    thinking: { type: 'disabled' }
  });
  console.log(JSON.stringify({ verdict: resp.choices[0]?.message?.content }, null, 2));
}
main().catch(e => { console.error('ERR:', e.message); process.exit(1); });
