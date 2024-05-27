require("fidget").setup {
  text = {
    spinner = "pipe", -- animation shown when tasks are ongoing
    done = "✔", -- character shown when all tasks are complete
    commenced = "Started", -- message shown when task starts
    completed = "Completed", -- message shown when task completes
  },
  timer = {
    spinner_rate = 125, -- frame rate of spinner animation, in ms
    fidget_decay = 10000, -- how long to keep around empty fidget, in ms
    task_decay = 5000, -- how long to keep around completed task, in ms
  },
}
