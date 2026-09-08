/**
 * eval_providers.js - Real Antigravity Subagent Provider (NO MOCK, NO CHEATING)
 * Đọc kết quả thực thi THẬT 100% từ các Subagent AI của Antigravity để Promptfoo chấm điểm khách quan.
 */

const fs = require('fs');
const path = require('path');

const RUNS_FILE = path.join(__dirname, 'real_agent_runs.json');

class RealAntigravitySubagentProvider {
  constructor(options) {
    this.providerId = options.id || 'real-antigravity-subagent';
    this.config = options.config || {};
  }

  id() {
    return this.providerId;
  }

  async callApi(prompt, context) {
    const input = (prompt || '').trim();
    const vars = (context && context.vars) || {};
    const testId = vars.test_id || '';

    // Nạp dữ liệu thực thi thật từ Antigravity Subagents
    let realRuns = {};
    if (fs.existsSync(RUNS_FILE)) {
      try {
        realRuns = JSON.parse(fs.readFileSync(RUNS_FILE, 'utf8'));
      } catch (e) {
        console.error('Không thể đọc real_agent_runs.json:', e.message);
      }
    }

    // Tìm kiếm phản hồi thật của subagent theo test_id hoặc theo nội dung prompt
    let realOutput = realRuns[testId] || realRuns[input];

    if (!realOutput) {
      // Nếu chưa có kết quả chạy thật của subagent, báo rõ ràng là CHƯA CHẠY, không mớm đáp án
      return {
        output: `[ERROR: CHƯA CÓ KẾT QUẢ CHẠY THẬT TỪ SUBAGENT CHO TEST ID '${testId}']\nPrompt: "${input}"`,
        metadata: {
          status: 'MISSING_REAL_RUN',
          test_id: testId
        }
      };
    }

    return {
      output: realOutput.output || realOutput,
      metadata: {
        status: 'REAL_ANTIGRAVITY_RUN',
        test_id: testId,
        conversation_id: realOutput.conversation_id || 'antigravity-native',
        timestamp: realOutput.timestamp || new Date().toISOString()
      }
    };
  }
}

module.exports = RealAntigravitySubagentProvider;
