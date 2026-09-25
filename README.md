# DSA612S — Assignment 1: Distributed Library and Resource Management System

**Course:** Distributed Systems and Applications (DSA612S)
**Faculty:** Computing and Informatics, School of Computing, Dept. of Software Engineering — NUST
**Due:** 14 September 2026, 23:59

> ⚠ **Academic integrity note (read this first):** the assignment brief
> states *"100% AI-generated code will be awarded a zero. AI tools should
> only be used as a guide,"* and requires the group to **present and
> defend** the solution. Treat everything in this repository as a
> reference implementation to study, test, adapt and rewrite in your own
> words as a group — not something to submit unread. None of this code
> has been compiled or run (no Ballerina toolchain was available while it
> was written), so budget real time to build, debug, and test it
> yourselves.

## Repository structure

```
.
├── library-management-system/       # Question 1 (50 marks) - RESTful API
│   ├── service/                      # Ballerina REST backend
│   ├── client/                       # Ballerina CLI client
│   └── README.md
└── rental-accommodation-system/     # Question 2 (50 marks) - gRPC
    ├── proto/rental.proto            # service + message contract
    ├── server/                       # Ballerina gRPC server
    ├── client/                       # Ballerina gRPC client
    └── README.md
```

Each sub-project has its own README with setup steps, an API/RPC
reference, curl/demo examples, and a design-notes section mapping the
code back to the mark scheme. Start there.

## Quick start

```bash
# Question 1
cd library-management-system/service && bal run &   # http://localhost:8080/library
cd ../client && bal run

# Question 2 — codegen is required first, see rental-accommodation-system/README.md
cd rental-accommodation-system/server && bal grpc --input ../proto/rental.proto --output . --mode service
bal run &
cd ../client && bal grpc --input ../proto/rental.proto --output .
bal run
```

## Before you submit

- [ ] `bal build` succeeds in all four packages (both `service`/`client`
      pairs), on a real Ballerina install — this was authored without one.
- [ ] Every group member is added as a contributor on GitHub/GitLab.
- [ ] Each member understands and can defend the parts they didn't write.
- [ ] Add a `.gitignore` for Ballerina build artifacts (`target/`).
- [ ] Optional but scored: bonus web/mobile front-end 
