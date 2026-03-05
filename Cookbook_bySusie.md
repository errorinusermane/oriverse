### 이제 Claude 창시자인 Boris가 말한 병렬 처리해보고자 설계

- VS code의 터미널에서 Claude를 병렬로 사용, 주로 plan
- 이때 git worktree를 사용해 모든 agents가 동시에 일할 때 충돌나지 않게 함
- VS code의 copilot은 최종적으로 코드를 완성할 때 사용

- 브랜치 만들고(그냥 뭐 진짜 평소에 하듯이 만들고 싶은 기능 위주)
- worktree 만들고(agent의 역할 이름으로 만들기, 이 부분이 병렬, 터미널 하나당 worktree 하나인 것)
- 병렬로 돌려서 기획/백엔드 계획까지 완료.
