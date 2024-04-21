# Makefile for COMP122 Programming Assignments
#   Allows students:
#     - to test their code
#     - to validate the structure of their submission
#     - to confirm their submission
#     - to understand how the Prof will grade their assignments

# Typically, there are three parts to every assignment.
#   Each part of the assignment must be associated with a single branch
#   For each part you want graded, a global tag MUST be associated a specific commit

# Minimum Requirements for Grading (per part)
#   1. A tracking branch must be established for said part
#   1. A minimal number of commits have been made to this branch
#   1. The branch must be merged with main when complete
#   1. A tag has been associated with this merge point
#   1. This tag has been been pushed to the origin
#   1. The commit date of the global tag must be on or BEFORE the DUE_DATE

# Associated Workflow
#    1. Create tracking branch
#       `git branch -c ${BRANCH}`
#       `git --set-upstream-to=origin ${BRANCH}
#    1. Development
#       `git switch ${BRANCH}`
#       LOOP:  edit, test, commit
#    1. Done:
#       `git switch main`
#       `git merge $BRANCH`
#       `git tag ${BRANCH}_submitted
#    1. Submit
#       `git push`
#       `git push origin ${BRANCH}`
#       `git push origin ${BRANCH}_submitted`


BRANCHES ?= java java_tac mips
BRANCH   ?= main
MIN_COMMITS=5

#########################################################################################----
# Variable Definitions associated with SUBMISSION

SUBMISSION=                      # Include for completeness
SUBMISSION_TAG=${BRANCH}_submitted

BRANCH_START=$(shell bin/git-branch-starting-point origin/${BRANCH})
NUM_COMMITS=$(shell git rev-list --count origin/${BRANCH} ^${BRANCH_START})

# Test the above
HAS_TAG=git show-ref --quiet --tags 
DUE_DATE ?= $(shell cat DUE_DATE)


#########################################################################################
# Variable Definitions associated with Makefile processing
SHELL=/bin/bash
TO_GRADE ?= grade_all
MAKEFILE ?= makefile


#########################################################################################----
# Make Targets explained
# 
# all: (the first target)
#   - the standard default target
#   - provides a menu to inform the student on top-level targets
#
# test_${BRANCH}:
#   - uses the simple testing harness (sth) to test the code within a directory
#   - it presumes the current work directory is correct
#   - does NOT require the code to be pushed to the remote
#   - does NOT perform any git operations
#
# validate:
# validate_${BRANCH}:
#   - checks the administrative requirements of the assignment
#   - used by the github to run a validation check of a student submission
#   - invoked by github via `make -k validate`
#
# confirm:
# confirm_${BRANCH}
#   - validates the administrative requirements are meet
#   - test the code as it appears in the remote, i.e., submitted code
#
# validate_*:
#   - a series of individual tests that validate one administrative requirement
#


all: 
	@echo 
	@echo "To test your java or mips code, \`cd\` to the correct directory and then type"
	@echo "  \"make test_java\" to test your current java version"
	@echo "  \"make test_mips\" to test your current mips version"
	@echo
	@echo "To validate the structure of your submission, \`cd\` to the top-level directory and then type"
	@echo "  \"make validate\" to validate your final submission"
	@echo "        \"make validate_java\" to validate just your java part"
	@echo "        \"make validate_java_tac\" to validate just your java_tac part"
	@echo "        \"make validate_mips\" to validate just your mips part"
	@echo 
	@echo "To confirm your assignment as been correctly submitted, "
	@echo "  \`cd\` to the top-level directory and then type"
	@echo "  \"make confirm\" to confirm your final submission"
	@echo "        \"make confirm_java\" to conform just your java part"
	@echo "        \"make confirm_java_tac\" to conform just your java_tac part"
	@echo "        \"make confirme_mips\" to confirm just your mips part"
	@echo 


############################################################################
test_java:
	STH_DRIVER=java_subroutine sth_validate ../test_cases 
test_java_tac:
	STH_DRIVER=java_subroutine sth_validate ../test_cases 
test_mips:
	STH_DRIVER=mips_subroutine sth_validate ../test_cases


############################################################################
validate:
	for x in ${BRANCH} ; do  \
	  BRANCH=$${x} make -f ${MAKEFILE} validate_branch ; \
	done

validate_java:
	BRANCH=java     make -f ${MAKEFILE} validate_branch
validate_java_tac:
	BRANCH=java_tac make -f ${MAKEFILE} validate_branch
validate_mips:
	BRANCH=mips     make -f ${MAKEFILE} validate_branch


############################################################################
confirm:
	for p in ${BRANCHES} ; do  \
	  BRANCH=$${p} make -f ${MAKEFILE} confirm_branch ; \
	done

confirm_java:
	BRANCH=java     make -f ${MAKEFILE} confirm_branch
confirm_java_tac:
	BRANCH=java_tac make -f ${MAKEFILE} confirm_branch
confirm_mips:
	BRANCH=mips     make -f ${MAKEFILE} confirm_branch


confirm_branch: validate_branch
	git switch --detach ${SUBMISSION_TAG}
	make --directory=${BRANCH} -f ${MAKEFILE} test_${BRANCH} 
	git switch main


############################################################################
validate_branch: validate_branch_exists validate_number_commits validate_merged validate_ontime

validate_branch_exists:
	@ [[ "$$(git branch --list ${BRANCH})" == "  ${BRANCH}" ]] || \
	  { echo "Branch ${BRANCH} does not exist" ; false ; }

validate_merged:
	@ [[ "$$(git branch --merged main ${BRANCH})" == "  ${BRANCH}" ]] || \
	  { echo "Branch ${BRANCH} has not been merged to main" ; false ; }

validate_number_commits: 
	@ [[ $(NUM_COMMITS) -ge $(MIN_COMMITS) ]]  ||  \
	  { echo "Pushed Branch Commits on ${BRANCH}:  $(NUM_COMMITS) < $(MIN_COMMITS) required commits" ; false ; }

validate_ontime: validate_tag validate_matched_tags DUE_DATE
	@ bin/git_tagged_ontime "${DUE_DATE}" ${SUBMISSION_TAG} || \
	  { echo "Due date violation: Due Date: ${DUE_DATE} ; tag=${SUBMISSION_TAG}";  false ; }

validate_tag:
	@ ${HAS_TAG} ${SUBMISSION_TAG} || \
	  { echo "Missing tag: ${SUBMISSION_TAG}" ; false ; }

validate_matched_tags: 
	@ bin/git_matched_tags ${SUBMISSION_TAG} || \
	  { echo "Remote/Local Tags Mismatch:  ${SUBMISSION_TAG} (hint \'git push origin submitted\')" ; false ; }




#
#  The following section is the code the prof will use to determine
#    - what he will and what he will not grade.
#  This section is left here for transparency.
#  His criteria for grading for a particular assignment may change!
#
#  At very most, he will grade 
#    - only material that is submitted by the due_date
#      * unless prior arrangements have been made
#    - a task based upon the point in time in which you asserted is done
#      * by virtue of appropriate tagging

pregrade: validate


grade: 
	for p in ${BRANCHES} ; do  \
	  BRANCH=$${p} make -f ${MAKEFILE} copy_code ; \
	  subl grading/$${p}
	done
	subl grading

copy_code: validate_branch || bash -lc 'checkout_due_date'
	mkdir -p grading 
	git switch ${BRANCH}_submitted   -- issue is that it might not be before due_date
	cp -R ${BRANCH} grading
	git switch main

